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
#include "Wedstrijd+create.h"
#include "CategorienCDTVC.h"
#include "KalenderCDTVC.h"

@interface FavorietePloegenCDTVC ()

@end

@implementation FavorietePloegenCDTVC

-(void)viewDidLoad
{
    [super viewDidLoad];
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Ploeg * ploeg = [self.fetchedResultsController objectAtIndexPath:indexPath];
        ploeg.isfavoriet = [NSNumber numberWithBool:NO];
        
        [Wedstrijd deleteWedstrijdenVoorPloeg:ploeg inManagedObjectContext:self.managedObjectContext];
        
        for (UILocalNotification *event in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSDictionary *userInfoCurrent = event.userInfo;
            
            if ([[userInfoCurrent valueForKey:@"pid"] intValue] == [ploeg.uniek intValue]) {
                [[UIApplication sharedApplication] cancelLocalNotification:event];
            }
        }
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
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
    } else if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
     
        if ([segue.destinationViewController respondsToSelector:@selector(setPloeg:)]) {
            [segue.destinationViewController performSelector:@selector(setPloeg:) withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
    }
}

- (IBAction)doneFavorite:(UIStoryboardSegue *)segue
{
    [self.tableView reloadData];
}

@end
