//
//  BattleDataFetcher.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetchable.h"

@class PokemonStats;

#pragma mark - BattleData Model

@interface BattleData : NSObject

@property (nonatomic, copy, readonly) NSArray *abilities; // Array of NSStrings
@property (nonatomic, strong, readonly) PokemonStats *stats;
@property (nonatomic, copy, readonly) NSArray *types;     // Array of NSDictionaries (Name and URL)

- (instancetype)initWithAbilities:(NSArray *)abilities
                            stats:(PokemonStats *)stats
                            types:(NSArray *)types;

@end

@interface MoveData : NSObject
@property (nonatomic, copy, readonly) NSString *damageClass;
@property (nonatomic, strong, readonly) NSNumber *power;
@property (nonatomic, copy, readonly) NSString *typeName;
@property (nonatomic, strong, readonly) NSURL *typeURL;
- (instancetype)initWithDamageClass:(NSString *)damageClass power:(NSNumber *)power typeName:(NSString *)typeName typeURL:(NSURL *)typeURL;
@end

@interface TypeData : NSObject
@property (nonatomic, copy, readonly) NSArray *doubleDamageTo;
@property (nonatomic, copy, readonly) NSArray *halfDamageTo;
@property (nonatomic, copy, readonly) NSArray *noDamageTo;
- (instancetype)initWithDoubleDamage:(NSArray *)doubleDamage halfDamage:(NSArray *)halfDamage noDamage:(NSArray *)noDamage;
@end


#pragma mark - BattleDataFetcher

@interface BattleDataFetcher : NSObject <APIFetchable>

// No extra methods needed in the header; the protocol handles the contract!

@end

@interface MoveDataFetcher : NSObject <APIFetchable>
@end

@interface TypeDataFetcher : NSObject <APIFetchable>
@end
