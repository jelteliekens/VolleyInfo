//
//  FavorietePloegenCDTVC.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface FavorietePloegenCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)doneFavorite:(UIStoryboardSegue *)segue;

@end
