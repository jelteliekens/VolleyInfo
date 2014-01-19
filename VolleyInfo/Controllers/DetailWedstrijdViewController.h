//
//  DetailWedstrijdViewController.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 23/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Wedstrijd.h"
#import "Ploeg.h"


@interface DetailWedstrijdViewController : UITableViewController <MKMapViewDelegate>

@property (nonatomic, strong) Wedstrijd *wedstrijd;
@property (nonatomic, strong) Ploeg *ploeg;

-(void) setPloeg:(Ploeg *) ploeg EnWedstrijd:(Wedstrijd *) wedstrijd;

@end
