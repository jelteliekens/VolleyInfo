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
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        ploeg.isfavoriet = [NSNumber numberWithBool:NO];
        
        [Wedstrijd deleteWedstrijdenVoorPloeg:ploeg inManagedObjectContext:self.categorie.managedObjectContext];
    }
    
    NSError *error;
    if (![self.categorie.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

@end
