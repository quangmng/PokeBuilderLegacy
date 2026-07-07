//
//  PokemonNamesFetcher.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "PokemonNamesFetcher.h"

#pragma mark - PokemonNamesData Implementation

@implementation PokemonNamesData

- (instancetype)initWithSpeciesCount:(NSInteger)speciesCount names:(NSArray *)names {
    self = [super init];
    if (self) {
        _speciesCount = speciesCount;
        _names = [names copy];
    }
    return self;
}

@end

#pragma mark - PokemonNamesFetcher Implementation

@implementation PokemonNamesFetcher

- (NSArray *)numberListWithSpecies:(NSInteger)species total:(NSInteger)total {
    NSMutableArray *list = [NSMutableArray array];
    NSInteger demarcation = 10000;
    
    // Add 1...species
    for (NSInteger i = 1; i <= species; i++) {
        [list addObject:@(i)];
    }
    
    // Add demarcation bounds (bound's bound??)
    NSInteger upperLimit = demarcation + total - species;
    for (NSInteger i = demarcation + 1; i <= upperLimit; i++) {
        [list addObject:@(i)];
    }
    
    return [list copy];
}

#pragma mark - APIFetchable Protocol

- (void)fetchWithParameters:(id)parameters completion:(APIFetchCompletion)completion {
    
    // In iOS 6, NSURLComponents didn't exist yet! Must manually append query parameters.
    NSString *namesEndpoint = @"https://pokeapi.co/api/v2/pokemon?limit=10000";
    NSURL *namesURL = [NSURL URLWithString:namesEndpoint];
    NSURLRequest *namesRequest = [NSURLRequest requestWithURL:namesURL];
    
    // Fire the first asynchronous network request (Names)
    [NSURLConnection sendAsynchronousRequest:namesRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *namesResponse, NSData *namesData, NSError *namesError) {
                               
                               // Guard against network errors
                               if (namesError || !namesData) {
                                   if (completion) completion(nil, namesError);
                                   return;
                               }
                               
                               // Parse the JSON manually using NSJSONSerialization
                               NSError *jsonError = nil;
                               NSDictionary *namesJSON = [NSJSONSerialization JSONObjectWithData:namesData options:0 error:&jsonError];
                               
                               if (jsonError || !namesJSON) {
                                   if (completion) completion(nil, jsonError);
                                   return;
                               }
                               
                               // Extract names using standard NSDictionary/NSArray traversal
                               NSArray *results = namesJSON[@"results"];
                               NSMutableArray *namesArray = [NSMutableArray arrayWithCapacity:results.count];
                               for (NSDictionary *pokemonDict in results) {
                                   [namesArray addObject:pokemonDict[@"name"]];
                               }
                               
                               // Fire the second asynchronous network request (Count) nested inside the first
                               NSString *countEndpoint = @"https://pokeapi.co/api/v2/pokemon-species?limit=10000";
                               NSURL *countURL = [NSURL URLWithString:countEndpoint];
                               NSURLRequest *countRequest = [NSURLRequest requestWithURL:countURL];
                               
                               [NSURLConnection sendAsynchronousRequest:countRequest
                                                                  queue:[NSOperationQueue mainQueue]
                                                      completionHandler:^(NSURLResponse *countResponse, NSData *countData, NSError *countError) {
                                                          
                                                          if (countError || !countData) {
                                                              if (completion) completion(nil, countError);
                                                              return;
                                                          }
                                                          
                                                          NSDictionary *countJSON = [NSJSONSerialization JSONObjectWithData:countData options:0 error:nil];
                                                          NSInteger count = [countJSON[@"count"] integerValue];
                                                          
                                                          // Both fetches succeeded. Assemble the final data object and pass it back.
                                                          PokemonNamesData *finalData = [[PokemonNamesData alloc] initWithSpeciesCount:count names:namesArray];
                                                          if (completion) completion(finalData, nil);
                                                      }];
                           }];
}

@end
