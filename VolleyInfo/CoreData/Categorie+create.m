//
//  Categorie+create.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Categorie+create.h"
#import "VolleyInfoFetcher.h"

@implementation Categorie (create)

+ (Categorie *)addCategorieMetInfo:(NSDictionary *)categorieDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Categorie * categorie = nil;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Categorie"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniek == %lu",
                         [[categorieDictionary[CATEGORIE_ID] description] integerValue]];
        
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
    } else if (![matches count]) {
        
        categorie = [NSEntityDescription insertNewObjectForEntityForName:@"Categorie" inManagedObjectContext:context];
        categorie.uniek = [NSNumber numberWithInteger:[[categorieDictionary[CATEGORIE_ID] description] integerValue]];
        categorie.naam = [categorieDictionary[CATEGORIE_NAAM] description];
        categorie.sort = [NSNumber numberWithInteger:[[categorieDictionary[CATEGORIE_SORT] description] integerValue]];
        
    } else {
        categorie = [matches lastObject];
        categorie.naam = [categorieDictionary[CATEGORIE_NAAM] description];
        categorie.sort = [NSNumber numberWithInteger:[[categorieDictionary[CATEGORIE_SORT] description] integerValue]];
    }
    
    return categorie;
}

+ (Categorie *)getCategorieMetId:(NSUInteger) categorieId
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    Categorie * categorie = nil;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Categorie"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniek == %lu", categorieId];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
        
    if (matches && [matches count] == 1) {
        categorie = [matches lastObject];
    }
    
    return categorie;
}

@end
