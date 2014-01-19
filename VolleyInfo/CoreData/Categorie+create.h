//
//  Categorie+create.h
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Categorie.h"

@interface Categorie (create)

+ (Categorie *)addCategorieMetInfo:(NSDictionary *)categorieDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Categorie *)getCategorieMetId:(NSUInteger) categorieId
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
