//
//  CategorienCDTVC.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 30/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "CategorienCDTVC.h"
#import "Categorie.h"
#import "PloegenVoorCategorieCDTVC.h"

@interface CategorienCDTVC ()

@end

@implementation CategorienCDTVC

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
            
    if (managedObjectContext) {
        
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Categorie"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categorien" forIndexPath:indexPath];
    
    Categorie * categorie = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = categorie.naam;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if ([segue.identifier isEqualToString:@"ploegenVoorCategorie"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(setCategorie:)]) {
                [segue.destinationViewController performSelector:@selector(setCategorie:)
                                                      withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            }
        }
    }
}

@end
