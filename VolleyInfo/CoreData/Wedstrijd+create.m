//
//  Wedstrijd+create.m
//  VolleyInfo
//
//  Created by Jelte Liekens on 13/12/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "Wedstrijd+create.h"
#import "VolleyInfoFetcher.h"

@implementation Wedstrijd (create)

+ (Wedstrijd *)addWedstrijdMetInfo:(NSDictionary *) wedstrijdDictionary
                 voorPloeg:(Ploeg *) ploeg
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Wedstrijd *wedstrijd = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Wedstrijd"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moment" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"ploeg == %@ AND uniek == %lu",
                         ploeg, [[wedstrijdDictionary[WEDSTRIJD_ID] description] integerValue]];
    
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
    } else if (![matches count]) {
        
        wedstrijd = [NSEntityDescription insertNewObjectForEntityForName:@"Wedstrijd" inManagedObjectContext:context];
        wedstrijd.uniek = [NSNumber numberWithInteger:[[wedstrijdDictionary[WEDSTRIJD_ID] description] integerValue]];
        wedstrijd.moment = [self parseMomentMetDatum:[wedstrijdDictionary[WEDSTRIJD_DATUM] description]
                                               enUur:[wedstrijdDictionary[WEDSTRIJD_UUR] description]];
        wedstrijd.ishome = [NSNumber numberWithBool:[[wedstrijdDictionary[WEDSTRIJD_IS_HOME] description] boolValue]];
        wedstrijd.resultaat = [wedstrijdDictionary[WEDSTRIJD_RESULTAAT] description];
        wedstrijd.type = [wedstrijdDictionary[WEDSTRIJD_TYPE] description];
        wedstrijd.sporthal = [self parseSporthal:[wedstrijdDictionary[WEDSTRIJD_SPORTHAL] description]];
        wedstrijd.tegenstander = [wedstrijdDictionary[WEDSTRIJD_TEGENST] description];
        wedstrijd.wedstrijdnr = [wedstrijdDictionary[WEDSTRIJD_WEDNR] description];
        wedstrijd.ploeg = ploeg;
        
    } else {
        wedstrijd = [matches lastObject];
        wedstrijd.moment = [self parseMomentMetDatum:[wedstrijdDictionary[WEDSTRIJD_DATUM] description]
                                               enUur:[wedstrijdDictionary[WEDSTRIJD_UUR] description]];
        wedstrijd.ishome = [NSNumber numberWithBool:[[wedstrijdDictionary[WEDSTRIJD_IS_HOME] description] boolValue]];
        wedstrijd.resultaat = [wedstrijdDictionary[WEDSTRIJD_RESULTAAT] description];
        wedstrijd.type = [wedstrijdDictionary[WEDSTRIJD_TYPE] description];
        wedstrijd.sporthal = [self parseSporthal:[wedstrijdDictionary[WEDSTRIJD_SPORTHAL] description]];
        wedstrijd.tegenstander = [wedstrijdDictionary[WEDSTRIJD_TEGENST] description];
        wedstrijd.wedstrijdnr = [wedstrijdDictionary[WEDSTRIJD_WEDNR] description];
        wedstrijd.ploeg = ploeg;
    }

    
    return wedstrijd;
}

+ (NSString *) parseSporthal: (NSString *) sporthal
{
    NSString *adres = nil;
    
    if (sporthal.length > 0) {
        NSArray *split = [sporthal componentsSeparatedByString:@","];
        
        if ([split count] >= 2) {
            adres = [NSString stringWithFormat:@"%@,%@", split[1], split[2]];
            adres = [adres stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    return adres;
}

+ (NSDate *)parseMomentMetDatum:(NSString *)datum enUur: (NSString *) uur
{
    NSString * moment = [NSString stringWithFormat:@"%@ %@", datum, uur];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd HH:mm"];
    
    return [formatter dateFromString:moment];
}

+ (Wedstrijd *) getVolgendeWedstrijdVoorPloeg:(Ploeg *) ploeg inManagedObjectContext:(NSManagedObjectContext *)context

{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Wedstrijd"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moment" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"NOT resultaat MATCHES '.-.' AND ploeg == %@", ploeg];
    request.fetchLimit = 1;
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    return [matches firstObject];
}

+ (void) deleteWedstrijdenVoorPloeg:(Ploeg *) ploeg inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Wedstrijd"];
    request.predicate = [NSPredicate predicateWithFormat:@"ploeg == %@", ploeg];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    for (Wedstrijd *wedstrijd in matches) {
        [context deleteObject:wedstrijd];
    }
}

@end
