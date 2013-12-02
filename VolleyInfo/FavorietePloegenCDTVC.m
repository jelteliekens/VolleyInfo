//
//  FavorietePloegenCDTVC.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "FavorietePloegenCDTVC.h"
#include "Ploeg.h"
#include "VolleyInfoFetcher.h"
#include "Categorie+create.h"
#include "Ploeg+create.h"
#include "CategorienCDTVC.h"

@interface FavorietePloegenCDTVC ()

@end

@implementation FavorietePloegenCDTVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self useDocument];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ploeg"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"categorie.sort" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"naam" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"isfavoriet == %@", [NSNumber numberWithBool:YES]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favorietePloegen" forIndexPath:indexPath];
    
    Ploeg *ploeg = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = ploeg.naam;
    cell.detailTextLabel.text = ploeg.niveau;
        
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([segue.identifier isEqualToString:@"voegFavorietToe"]) {
            if ([[segue.destinationViewController visibleViewController] respondsToSelector:@selector(setManagedObjectContext:)]) {
                [[segue.destinationViewController visibleViewController] performSelector:@selector(setManagedObjectContext:)
                                                                              withObject:self.managedObjectContext];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Ploeg * ploeg = [self.fetchedResultsController objectAtIndexPath:indexPath];
        ploeg.isfavoriet = [NSNumber numberWithBool:NO];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

- (IBAction)doneFavorite:(UIStoryboardSegue *)segue
{
    [self.tableView reloadData];
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
                [self refresh];
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

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("VolleyInfoFetch", NULL);
    dispatch_async(fetchQ, ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *categorien = [VolleyInfoFetcher getCategorien];
        NSArray *ploegen = [VolleyInfoFetcher getPloegen];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.managedObjectContext performBlock:^{
            
            for (NSDictionary *categorie in categorien) {
                [Categorie categorieMetInfo:categorie inManagedObjectContext:self.managedObjectContext];
            }
            
            for (NSDictionary *ploeg in ploegen) {
                [Ploeg ploegMetInfo:ploeg inManagedObjectContext:self.managedObjectContext];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

@end
