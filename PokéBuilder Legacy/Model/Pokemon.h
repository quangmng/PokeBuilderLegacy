//
//  Pokemon.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 6/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "IDGeneratable.h"

// Forward declaration of upcoming PokemonStats model
@class PokemonStats;

@interface Pokemon : NSObject <IDGeneratable, NSCopying>

// Read-only identifiers
@property (nonatomic, assign, readonly) NSInteger pokemonID;
@property (nonatomic, assign, readonly) NSInteger pokemonNumber;


// Customisable attributes (read-write)
@property (nonatomic, copy) NSString *item;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSString *ability;
@property (nonatomic, copy) PokemonStats *effortValues;
@property (nonatomic, copy) NSString *nature;

- (instancetype)initWithID:(NSInteger)pokemonID
             pokemonNumber:(NSInteger)pokemonNumber
                      item:(NSString *)item
                     level:(NSInteger)level
                   ability:(NSString *)ability
              effortValues:(PokemonStats *)effortValues
                    nature:(NSString *)nature;

// Domain-specific restrictions
+ (NSInteger)maxLevel;
+ (NSInteger)minLevel;
+ (NSInteger)maxEVs;
+ (NSInteger)minEVs;

// Validation helpers
+ (NSInteger)clipEV:(NSInteger)value;
+ (NSInteger)validLevel:(NSInteger)level;
+ (PokemonStats *)validEVs:(PokemonStats *)stats;

@end