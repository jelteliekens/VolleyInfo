//
//  PloegenVoorCategorieCDTVC.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 30/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "PloegenVoorCategorieCDTVC.h"
#import "Ploeg.h"
#import "Wedstrijd+create.h"
#import "VolleyInfoFetcher.h"

@interface PloegenVoorCategorieCDTVC ()

@end

@implementation PloegenVoorCategorieCDTVC

-(void)setCategorie:(Categorie *)categorie
{
    _categorie = categorie;
    self.title = categorie.naam;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController {
    
    if (self.categorie.managedObjectContext) {
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Ploeg"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"naam" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"categorie == %@", self.categorie];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.categorie.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ploegenPerCategorie" forIndexPath:indexPath];
    
    Ploeg * ploeg = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString * labelText = ploeg.naam;
    if ([ploeg.niveau length] > 0) {
        labelText = [labelText stringByAppendingString:[NSString stringWithFormat:@" (%@)",ploeg.niveau]];
    }
    cell.textLabel.text = labelText;
    
    if ([ploeg.isfavoriet boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Ploeg *ploeg = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        ploeg.isfavoriet = [NSNumber numberWithBool:YES];
        
        [self fetchWedstrijdenVanPloeg:ploeg inManagedObjectContext:self.categorie.managedObjectContext];
        
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        ploeg.isfavoriet = [NSNumber numberWithBool:NO];
        
        [Wedstrijd deleteWedstrijdenVoorPloeg:ploeg inManagedObjectContext:self.categorie.managedObjectContext];
        
        for (UILocalNotification *event in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            NSDictionary *userInfoCurrent = event.userInfo;
            
            if ([[userInfoCurrent valueForKey:@"pid"] intValue] == [ploeg.uniek intValue]) {
                [[UIApplication sharedApplication] cancelLocalNotification:event];
            }
        }
    }
    
    NSError *error;
    if (![self.categorie.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void) fetchWedstrijdenVanPloeg:(Ploeg *)ploeg inManagedObjectContext: (NSManagedObjectContext *)context
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Fetch wedstrijden", NULL);
    dispatch_async(fetchQ, ^{
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *wedstrijden = [VolleyInfoFetcher getWedstrijdenVanPloeg: [ploeg.uniek integerValue]];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [context performBlock:^{
            
            for (NSDictionary *wedstrijd in wedstrijden) {
                [Wedstrijd addWedstrijdMetInfo:wedstrijd voorPloeg:ploeg inManagedObjectContext:context];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
    });
}

@end
