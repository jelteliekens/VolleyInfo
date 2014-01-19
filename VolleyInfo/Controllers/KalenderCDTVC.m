//
//  KalenderCDTVC.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 13/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "KalenderCDTVC.h"
#import "VolleyInfoFetcher.h"
#import "KalenderOverviewCell.h"
#import "DetailWedstrijdViewController.h"
#import "Wedstrijd+create.h"
#import "Ploeg+create.h"
#import "Categorie+create.h"
#import "FavorietePloegenCDTVC.h"

@interface KalenderCDTVC ()

@end

@implementation KalenderCDTVC

#define PLOEG_ID_PLIST @"PloegId"

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self useDocument];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshAlles];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSInteger ploegId = [[NSUserDefaults standardUserDefaults] integerForKey:PLOEG_ID_PLIST];
    Ploeg *pl =[Ploeg getPloegMetId:ploegId InManagedObjectContext:self.managedObjectContext];
    self.ploeg = pl;
}

- (void)setPloeg:(Ploeg *)ploeg
{
    _ploeg = ploeg;
    [self setupFetchedResultsController];
    self.title = ploeg.naam;
}

- (void)setupFetchedResultsController {
    
    if (self.managedObjectContext) {
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Wedstrijd"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moment" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"ploeg == %@", self.ploeg];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.ploeg.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                    cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void) scrollNaarWedstrijd
{
    [self.tableView scrollToRowAtIndexPath:[self.fetchedResultsController indexPathForObject:[Wedstrijd getVolgendeWedstrijdVoorPloeg:self.ploeg
                                                                                                               inManagedObjectContext:self.ploeg.managedObjectContext]]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KalenderOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KalenderItem" forIndexPath:indexPath];
    
    Wedstrijd * wedstrijd = [self.fetchedResultsController objectAtIndexPath:indexPath];
    bool ishome = [wedstrijd.ishome boolValue];
    
    cell.ploeg.text = wedstrijd.tegenstander;
    cell.uitslag.text = wedstrijd.resultaat;
    
    if(wedstrijd == [Wedstrijd getVolgendeWedstrijdVoorPloeg:self.ploeg inManagedObjectContext:self.ploeg.managedObjectContext]) {
        float greyColor = 235;
        cell.backgroundColor = [UIColor colorWithRed:(greyColor/255.f) green:(greyColor/255.f) blue:(greyColor/255.f) alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSArray*score = [wedstrijd.resultaat componentsSeparatedByString:@"-"];
    
    if ([score count] == 2) {
        if ((ishome && [score[0] isEqualToString:@"3"]) || (!ishome && [score[1] isEqualToString:@"3"])) {
            cell.uitslag.textColor = [UIColor colorWithRed:(99/255.f) green:(150/255.f) blue:(38/255.f) alpha:1];
        } else {
            cell.uitslag.textColor = [UIColor redColor];
        }
    }
        
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    cell.moment.text = [formatter stringFromDate:wedstrijd.moment];
    
    NSString *plaats = nil;
    
    if (ishome) {
        plaats = @"Thuis";
    } else {
        plaats = @"Verplaatsing";
    }
    cell.plaats.text = plaats;
     
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
        
        if ([segue.identifier isEqualToString:@"detailWedstrijd"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setPloeg:EnWedstrijd:)]) {
                [segue.destinationViewController performSelector:@selector(setPloeg:EnWedstrijd:) withObject:self.ploeg withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            }
        }
    } else {
        if ([segue.identifier isEqualToString:@"kiesFavoriet"]) {
            FavorietePloegenCDTVC *controller = (FavorietePloegenCDTVC *)[segue.destinationViewController visibleViewController];
            controller.managedObjectContext = self.managedObjectContext;
        }
    }
}


-(void) useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"SQLiteDocument"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self refreshAlles];
            }
        }];
        
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}

- (IBAction)refreshAlles
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Fetch Ploegen en categorieen", NULL);
    dispatch_async(fetchQ, ^{
        
        NSMutableDictionary *alleWedstrijden = [[NSMutableDictionary alloc] init];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *categorien = [VolleyInfoFetcher getCategorien];
        NSArray *ploegen = [VolleyInfoFetcher getPloegen];
        for (Ploeg *ploeg in [Ploeg getFavorietePloegenInManagedObjectContext:self.managedObjectContext]) {
            NSArray *test = [VolleyInfoFetcher getWedstrijdenVanPloeg: [ploeg.uniek integerValue]];
            [alleWedstrijden setObject:test forKey:ploeg.uniek];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.managedObjectContext performBlock:^{
            
            for (NSDictionary *categorieDict in categorien) {
                [Categorie addCategorieMetInfo:categorieDict inManagedObjectContext:self.managedObjectContext];
            }
            
            for (NSDictionary *ploegDict in ploegen) {
                [Ploeg addPloegMetInfo:ploegDict inManagedObjectContext:self.managedObjectContext];
            }
            
            for (NSString* ploegId in [alleWedstrijden allKeys]) {
                for (NSDictionary *wedstrijd in [alleWedstrijden objectForKey:ploegId]) {
                    [Wedstrijd addWedstrijdMetInfo:wedstrijd voorPloeg:[Ploeg getPloegMetId:[ploegId integerValue] InManagedObjectContext:self.managedObjectContext] inManagedObjectContext:self.managedObjectContext];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}


- (IBAction)favorietePloegGekozen:(UIStoryboardSegue*)segue
{
    [self scrollNaarWedstrijd];
    
    NSInteger ploegId = [[NSUserDefaults standardUserDefaults] integerForKey:PLOEG_ID_PLIST];
    ploegId = [self.ploeg.uniek integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:ploegId forKey:PLOEG_ID_PLIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
