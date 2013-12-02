//
//  Ploeg.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 30/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categorie, Wedstrijd;

@interface Ploeg : NSManagedObject

@property (nonatomic, retain) NSNumber * isfavoriet;
@property (nonatomic, retain) NSString * naam;
@property (nonatomic, retain) NSString * niveau;
@property (nonatomic, retain) NSString * shortnaam;
@property (nonatomic, retain) NSNumber * uniek;
@property (nonatomic, retain) Categorie *categorie;
@property (nonatomic, retain) NSSet *wedstrijden;
@end

@interface Ploeg (CoreDataGeneratedAccessors)

- (void)addWedstrijdenObject:(Wedstrijd *)value;
- (void)removeWedstrijdenObject:(Wedstrijd *)value;
- (void)addWedstrijden:(NSSet *)values;
- (void)removeWedstrijden:(NSSet *)values;

@end
