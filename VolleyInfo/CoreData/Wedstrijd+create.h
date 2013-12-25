//
//  Wedstrijd+create.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 13/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Wedstrijd.h"

@interface Wedstrijd (create)

+ (Wedstrijd *)wedstrijdMetInfo:(NSDictionary *) wedstrijdDictionary
                 voorPloeg:(Ploeg *) ploeg
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Wedstrijd *) getVolgendeWedstrijdVoorPloeg:(Ploeg *) ploeg inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void) deleteWedstrijdenVoorPloeg:(Ploeg *) ploeg inManagedObjectContext:(NSManagedObjectContext *)context;

@end
