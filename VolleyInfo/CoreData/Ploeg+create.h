//
//  Ploeg+create.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Ploeg.h"

@interface Ploeg (create)

+ (Ploeg *)addPloegMetInfo:(NSDictionary *)ploegDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Ploeg *) getPloegMetId:(NSUInteger)ploegId InManagedObjectContext: (NSManagedObjectContext *)context;

+ (NSArray *) getFavorietePloegenInManagedObjectContext: (NSManagedObjectContext *)context;

@end
