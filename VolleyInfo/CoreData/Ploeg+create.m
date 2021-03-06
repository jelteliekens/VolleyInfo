//
//  Ploeg+create.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Ploeg+create.h"
#import "VolleyInfoFetcher.h"
#import "Categorie+create.h"

@implementation Ploeg (create)

+ (Ploeg *)addPloegMetInfo:(NSDictionary *)ploegDictionary
 inManagedObjectContext:(NSManagedObjectContext *)context
{
    Ploeg * ploeg = nil;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Ploeg"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"naam" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniek == %lu",
                         [[ploegDictionary[PLOEG_ID] description] integerValue]];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
        
    if (!matches || ([matches count] > 1)) {
        
    } else if (![matches count]) {
        
        ploeg = [NSEntityDescription insertNewObjectForEntityForName:@"Ploeg" inManagedObjectContext:context];
        ploeg.uniek = [NSNumber numberWithInteger: [[ploegDictionary[PLOEG_ID] description] integerValue]];
        ploeg.naam = [ploegDictionary[PLOEG_NAAM] description];
        ploeg.niveau = [ploegDictionary[PLOEG_NIVEAU] description];
        ploeg.shortnaam = [ploegDictionary[PLOEG_SHORTNAAM] description];
        ploeg.isfavoriet = [NSNumber numberWithBool:NO];
        ploeg.categorie = [Categorie getCategorieMetId:[[ploegDictionary[PLOEG_CATEGORIE_ID] description] integerValue]
                             inManagedObjectContext:context];
        
    } else {
        ploeg = [matches lastObject];
        ploeg.naam = [ploegDictionary[PLOEG_NAAM] description];
        ploeg.niveau = [ploegDictionary[PLOEG_NIVEAU] description];
        ploeg.shortnaam = [ploegDictionary[PLOEG_SHORTNAAM] description];
        ploeg.categorie = [Categorie getCategorieMetId:[[ploegDictionary[PLOEG_CATEGORIE_ID] description] integerValue]
                             inManagedObjectContext:context];
    }
    
    return ploeg;
}

+ (Ploeg *) getPloegMetId:(NSUInteger)ploegId InManagedObjectContext: (NSManagedObjectContext *)context
{
    Ploeg * ploeg = nil;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Ploeg"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"naam" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniek == 2"];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    if (matches && [matches count] == 1) {
        ploeg = [matches lastObject];
    }
    
    return ploeg;
}

+ (NSArray *) getFavorietePloegenInManagedObjectContext: (NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ploeg"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"categorie.sort" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"naam" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"isfavoriet == %@", [NSNumber numberWithBool:YES]];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    return matches;
}

@end
