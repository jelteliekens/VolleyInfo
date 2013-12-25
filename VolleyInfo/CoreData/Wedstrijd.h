//
//  Wedstrijd.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 13/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ploeg;

@interface Wedstrijd : NSManagedObject

@property (nonatomic, retain) NSNumber * ishome;
@property (nonatomic, retain) NSDate * moment;
@property (nonatomic, retain) NSString * resultaat;
@property (nonatomic, retain) NSString * sporthal;
@property (nonatomic, retain) NSString * tegenstander;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * uniek;
@property (nonatomic, retain) NSString * wedstrijdnr;
@property (nonatomic, retain) Ploeg *ploeg;

@end
