//
//  BattleDataFetcher.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "BattleDataFetcher.h"
#import "PokemonStats.h"

#pragma mark - BattleData Implementation

@implementation BattleData

- (instancetype)initWithAbilities:(NSArray *)abilities
                            stats:(PokemonStats *)stats
                            types:(NSArray *)types {
    self = [super init];
    if (self) {
        _abilities = [abilities copy];
        _stats = stats;
        _types = [types copy];
    }
    return self;
}

@end

#pragma mark - BattleDataFetcher Implementation

@implementation BattleDataFetcher

- (void)fetchWithParameters:(id)parameters completion:(APIFetchCompletion)completion {
    
    // 1. Safety check: Ensure the caller passed in an NSNumber.
    if (![parameters isKindOfClass:[NSNumber class]]) {
        // If they passed something invalid, we create a custom NSError and bail out early.
        NSError *typeError = [NSError errorWithDomain:@"com.legacy.app" code:100 userInfo:nil];
        if (completion) completion(nil, typeError);
        return;
    }
    
    NSInteger pokemonNumber = [parameters integerValue];
    
    // 2. String Formatting in Objective-C
    NSString *endpoint = [NSString stringWithFormat:@"https://pokeapi.co/api/v2/pokemon/%ld", (long)pokemonNumber];
    NSURL *url = [NSURL URLWithString:endpoint];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. Fire the asynchronous network call
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error || !data) {
                                   if (completion) completion(nil, error);
                                   return;
                               }
                               
                               NSError *jsonError = nil;
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               
                               if (jsonError || !json) {
                                   if (completion) completion(nil, jsonError);
                                   return;
                               }
                               
                               // --- PARSING RAW DATA ---
                               
                               // A. Parse Abilities
                               NSArray *rawAbilities = json[@"abilities"];
                               NSMutableArray *abilitiesArray = [NSMutableArray arrayWithCapacity:rawAbilities.count];
                               for (NSDictionary *abilityDict in rawAbilities) {
                                   NSString *name = abilityDict[@"ability"][@"name"];
                                   if (name) [abilitiesArray addObject:name];
                               }
                               
                               // B. Parse Stats (Reusing our PokemonStats object!)
                               NSArray *rawStats = json[@"stats"];
                               PokemonStats *battleStats = [PokemonStats emptyEVs]; // Gives us a clean slate of 0s
                               NSArray *statNames = @[@"HP", @"Atk", @"Def", @"SpA", @"SpD", @"Spe"];
                               
                               for (NSUInteger i = 0; i < statNames.count && i < rawStats.count; i++) {
                                   NSInteger baseValue = [rawStats[i][@"base_stat"] integerValue];
                                   [battleStats addStatWithName:statNames[i] value:baseValue];
                               }
                               
                               // C. Parse Types (Faking Tuples using NSDictionary)
                               NSArray *rawTypes = json[@"types"];
                               NSMutableArray *typesArray = [NSMutableArray arrayWithCapacity:rawTypes.count];
                               for (NSDictionary *typeDict in rawTypes) {
                                   NSString *name = typeDict[@"type"][@"name"];
                                   NSString *urlString = typeDict[@"type"][@"url"];
                                   
                                   if (name && urlString) {
                                       NSURL *typeUrl = [NSURL URLWithString:urlString];
                                       if (typeUrl) {
                                           NSDictionary *typeTuple = @{@"name": name, @"url": typeUrl};
                                           [typesArray addObject:typeTuple];
                                       }
                                   }
                               }
                               
                               // 4. Assemble the final domain object
                               BattleData *finalData = [[BattleData alloc] initWithAbilities:abilitiesArray
                                                                                       stats:battleStats
                                                                                       types:typesArray];
                               
                               // 5. Send it back to the caller
                               if (completion) completion(finalData, nil);
                           }];
}


@end
