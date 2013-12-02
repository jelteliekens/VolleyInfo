//
//  Ploeg+create.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Ploeg.h"

@interface Ploeg (create)

+ (Ploeg *)ploegMetInfo:(NSDictionary *)ploegDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
