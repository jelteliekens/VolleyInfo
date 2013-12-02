//
//  VolleyInfoFetcher.m
//  MendoAPI
//
//  Created by Jelte Liekens on 29/11/13.
//  Copyright (c) 2013 Jelte Liekens. All rights reserved.
//

#import "VolleyInfoFetcher.h"

@implementation VolleyInfoFetcher

+ (NSDictionary *)executeFlickrFetch:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@", query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (NSLOG_VOLLEYINFO) NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);
    [NSThread sleepForTimeInterval:2.0];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    if (NSLOG_VOLLEYINFO) NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    return results;
}

+ (NSArray *) getCategorien {
    
    NSString *request = @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=categorie";
    return [[self executeFlickrFetch:request] valueForKey:@"result"];
}

+ (NSDictionary *) getCategorieMetId: (NSUInteger) categorieId {
    NSString *request = [NSString stringWithFormat: @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=categorie&id=%lu", (unsigned long)categorieId];
    return [[self executeFlickrFetch:request] valueForKey:@"result"];
}

+ (NSArray *) getPloegen {
    NSString *request = @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=ploeg";
    return [[self executeFlickrFetch:request] valueForKey:@"result"];
}

+ (NSDictionary *) getPloegMetId: (NSUInteger) ploegId {
    NSString *request = [NSString stringWithFormat: @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=ploeg&id=%lu", (unsigned long)ploegId];
    return [[self executeFlickrFetch:request] valueForKey:@"result"];
}

+ (NSArray *) getWedstrijden {
    NSString *request = @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=wedstrijd";
    return [[self executeFlickrFetch:request] valueForKey:@"result"];
}

+ (NSDictionary *) getWedstrijdMetId: (NSUInteger) wedstrijdId {
    NSString *request = [NSString stringWithFormat: @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=wedstrijd&wid=%lu", (unsigned long)wedstrijdId];
    return [[self executeFlickrFetch:request] valueForKeyPath:@"result"];
}

+ (NSArray *) getWedstrijdenVanPloeg: (NSUInteger) ploegId {
    NSString *request = [NSString stringWithFormat: @"https://r0430078.webontwerp.khleuven.be/mendoapi/?action=wedstrijd&pid=%lu", (unsigned long)ploegId];
    return [[self executeFlickrFetch:request] valueForKey:@"result"];
}

@end
