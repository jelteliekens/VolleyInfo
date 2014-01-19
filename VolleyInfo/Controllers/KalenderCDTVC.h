//
//  KalenderCDTVC.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 13/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Ploeg.h"

@interface KalenderCDTVC : CoreDataTableViewController

@property (nonatomic, strong) Ploeg * ploeg;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)favorietePloegGekozen:(UIStoryboardSegue *)segue;

@end
