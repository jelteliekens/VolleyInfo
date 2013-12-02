//
//  Categorie.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ploeg;

@interface Categorie : NSManagedObject

@property (nonatomic, retain) NSNumber * uniek;
@property (nonatomic, retain) NSString * naam;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSSet *ploegen;
@end

@interface Categorie (CoreDataGeneratedAccessors)

- (void)addPloegenObject:(Ploeg *)value;
- (void)removePloegenObject:(Ploeg *)value;
- (void)addPloegen:(NSSet *)values;
- (void)removePloegen:(NSSet *)values;

@end
