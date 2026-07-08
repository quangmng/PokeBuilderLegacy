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
    
    // Safety check: Ensure the caller passed in an NSNumber.
    if (![parameters isKindOfClass:[NSNumber class]]) {
        // If they passed something invalid, create a custom NSError and bail out.
        NSError *typeError = [NSError errorWithDomain:@"com.legacy.app" code:100 userInfo:nil];
        if (completion) completion(nil, typeError);
        return;
    }
    
    NSInteger pokemonNumber = [parameters integerValue];
    
    // String Formatting in Objective-C
    NSString *endpoint = [NSString stringWithFormat:@"https://pokeapi.co/api/v2/pokemon/%ld", (long)pokemonNumber];
    NSURL *url = [NSURL URLWithString:endpoint];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Fire the asynchronous network call
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
                               
                               // PARSING RAW DATA
                               
                               // Parse Abilities
                               NSArray *rawAbilities = json[@"abilities"];
                               NSMutableArray *abilitiesArray = [NSMutableArray arrayWithCapacity:rawAbilities.count];
                               for (NSDictionary *abilityDict in rawAbilities) {
                                   NSString *name = abilityDict[@"ability"][@"name"];
                                   if (name) [abilitiesArray addObject:name];
                               }
                               
                               // Parse Stats (Reusing PokemonStats object)
                               NSArray *rawStats = json[@"stats"];
                               PokemonStats *battleStats = [PokemonStats emptyEVs]; // 0-ing every stat
                               NSArray *statNames = @[@"HP", @"Atk", @"Def", @"SpA", @"SpD", @"Spe"];
                               
                               for (NSUInteger i = 0; i < statNames.count && i < rawStats.count; i++) {
                                   NSInteger baseValue = [rawStats[i][@"base_stat"] integerValue];
                                   [battleStats addStatWithName:statNames[i] value:baseValue];
                               }
                               
                               // Parse Types (Faking Tuples using NSDictionary)
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
                               
                               // Assemble the final domain object
                               BattleData *finalData = [[BattleData alloc] initWithAbilities:abilitiesArray
                                                                                       stats:battleStats
                                                                                       types:typesArray];
                               
                               // Send it back to the caller
                               if (completion) completion(finalData, nil);
                           }];
}


@end

#pragma mark - Additional Data Models

@implementation MoveData

- (instancetype)initWithDamageClass:(NSString *)damageClass
                              power:(NSNumber *)power
                           typeName:(NSString *)typeName
                            typeURL:(NSURL *)typeURL {
    self = [super init];
    if (self) {
        _damageClass = [damageClass copy];
        _power = power;
        _typeName = [typeName copy];
        _typeURL = typeURL;
    }
    return self;
}

@end

@implementation TypeData

- (instancetype)initWithDoubleDamage:(NSArray *)doubleDamage
                          halfDamage:(NSArray *)halfDamage
                            noDamage:(NSArray *)noDamage {
    self = [super init];
    if (self) {
        _doubleDamageTo = [doubleDamage copy];
        _halfDamageTo = [halfDamage copy];
        _noDamageTo = [noDamage copy];
    }
    return self;
}

@end


#pragma mark - Additional Fetchers

@implementation MoveDataFetcher

- (void)fetchWithParameters:(id)parameters completion:(APIFetchCompletion)completion {
    if (![parameters isKindOfClass:[NSString class]]) {
        if (completion) completion(nil, [NSError errorWithDomain:@"com.legacy.app" code:101 userInfo:nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"https://pokeapi.co/api/v2/move/%@", parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error || !data) {
                                   if (completion) completion(nil, error);
                                   return;
                               }
                               
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               if (!json) {
                                   if (completion) completion(nil, nil);
                                   return;
                               }
                               
                               NSString *damageClass = json[@"damage_class"][@"name"];
                               id rawPower = json[@"power"];
                               NSNumber *power = (rawPower && ![rawPower isKindOfClass:[NSNull class]]) ? rawPower : nil;
                               
                               NSString *typeName = json[@"type"][@"name"];
                               NSString *urlString = json[@"type"][@"url"];
                               NSURL *typeURL = urlString ? [NSURL URLWithString:urlString] : nil;
                               
                               MoveData *moveData = [[MoveData alloc] initWithDamageClass:damageClass
                                                                                    power:power
                                                                                 typeName:typeName
                                                                                  typeURL:typeURL];
                               
                               if (completion) completion(moveData, nil);
                           }];
}

@end


@implementation TypeDataFetcher

- (void)fetchWithParameters:(id)parameters completion:(APIFetchCompletion)completion {
    if (![parameters isKindOfClass:[NSURL class]]) {
        if (completion) completion(nil, [NSError errorWithDomain:@"com.legacy.app" code:102 userInfo:nil]);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:parameters];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error || !data) {
                                   if (completion) completion(nil, error);
                                   return;
                               }
                               
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               if (!json) {
                                   if (completion) completion(nil, nil);
                                   return;
                               }
                               
                               NSDictionary *relations = json[@"damage_relations"];
                               
                               NSArray* (^extractNames)(NSString*) = ^NSArray*(NSString *key) {
                                   NSMutableArray *names = [NSMutableArray array];
                                   for (NSDictionary *dict in relations[key]) {
                                       if (dict[@"name"]) [names addObject:dict[@"name"]];
                                   }
                                   return names;
                               };
                               
                               TypeData *typeData = [[TypeData alloc] initWithDoubleDamage:extractNames(@"double_damage_to")
                                                                                halfDamage:extractNames(@"half_damage_to")
                                                                                  noDamage:extractNames(@"no_damage_to")];
                               
                               if (completion) completion(typeData, nil);
                           }];
}

@end
