//
//  KalenderCDTVC.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 13/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "KalenderCDTVC.h"
#import "Wedstrijd+create.h"
#import "VolleyInfoFetcher.h"
#import "KalenderOverviewCell.h"
#import "DetailWedstrijdViewController.h"

@interface KalenderCDTVC ()

@end

@implementation KalenderCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self scrollNaarPloeg];
}

- (void)setPloeg:(Ploeg *)ploeg
{
    _ploeg = ploeg;
    [self setupFetchedResultsController];
    [self refresh];
}

- (void)setupFetchedResultsController {
    
    if (self.ploeg.managedObjectContext) {
        
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

- (void) scrollNaarPloeg
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
    }
}

- (void) refresh
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Fetch wedstrijden", NULL);
    dispatch_async(fetchQ, ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *wedstrijden = [VolleyInfoFetcher getWedstrijdenVanPloeg: [self.ploeg.uniek integerValue]];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.ploeg.managedObjectContext performBlock:^{
            
            for (NSDictionary *wedstrijd in wedstrijden) {
                [Wedstrijd wedstrijdMetInfo:wedstrijd voorPloeg:self.ploeg inManagedObjectContext:self.ploeg.managedObjectContext];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self scrollNaarPloeg];
            });
        }];
    });
}

@end
