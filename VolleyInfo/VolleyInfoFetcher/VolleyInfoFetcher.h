//
//  VolleyInfoFetcher.h
//  MendoAPI
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CATEGORIE_ID @"id"
#define CATEGORIE_NAAM @"naam"
#define CATEGORIE_SORT @"sort"

#define PLOEG_ID @"id"
#define PLOEG_CATEGORIE_ID @"categorie_id"
#define PLOEG_NAAM @"naam"
#define PLOEG_NIVEAU @"niveau"
#define PLOEG_SHORTNAAM @"shortnaam"

#define WEDSTRIJD_ID @"id"
#define WEDSTRIJD_IS_HOME @"ishome"
#define WEDSTRIJD_WEDNR @"wedstrijdnummer"
#define WEDSTRIJD_RESULTAAT @"resultaat"
#define WEDSTRIJD_SPORTHAL @"sporthal"
#define WEDSTRIJD_DATUM @"datum"
#define WEDSTRIJD_PLOEGID @"ploeg_id"
#define WEDSTRIJD_TEGENST @"tegenstander"
#define WEDSTRIJD_UUR @"uur"
#define WEDSTRIJD_TYPE @"type"

#define NSLOG_VOLLEYINFO NO

@interface VolleyInfoFetcher : NSObject

+ (NSArray *) getCategorien;

+ (NSDictionary *) getCategorieMetId: (NSUInteger) categorieId;

+ (NSArray *) getPloegen;

+ (NSDictionary *) getPloegMetId: (NSUInteger) ploegId;

+ (NSArray *) getWedstrijden;

+ (NSDictionary *) getWedstrijdMetId: (NSUInteger) wedstrijdId;

+ (NSArray *) getWedstrijdenVanPloeg: (NSUInteger) ploegId;

@end
