//
//  Pokemon.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 6/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "Pokemon.h"
#import "PokemonStats.h"

static NSInteger sNextId = 1;

// Private C-function for internal clipping logic.
static NSInteger clipValue(NSInteger value, NSInteger lowerBound, NSInteger upperBound) {
    // MAX returns the higher of two values, MIN returns the lower.
    return MAX(lowerBound, MIN(value, upperBound));
}

@implementation Pokemon

#pragma mark - Initialisation

- (instancetype)initWithID:(NSInteger)pokemonID
             pokemonNumber:(NSInteger)pokemonNumber
                     level:(NSInteger)level
                   ability:(NSString *)ability
              effortValues:(PokemonStats *)effortValues
                    nature:(NSString *)nature
                    moves:(NSArray *)moves  {
    self = [super init];
    if (self) {
        _pokemonID = pokemonID;
        _pokemonNumber = pokemonNumber;
        _level = [Pokemon validLevel:level];
        _ability = [ability copy];
        
        // Validating EVs upon initialisation
        _effortValues = [Pokemon validEVs:effortValues];
        _nature = [nature copy];
        _moves = [Pokemon validMoves:moves];
    }
    return self;
}

#pragma mark - Domain Logic (Class Methods)

+ (NSInteger)maxLevel { return 100; }
+ (NSInteger)minLevel { return 1; }
+ (NSInteger)maxEVs { return 252; }
+ (NSInteger)minEVs { return 0; }

+ (NSInteger)clipEV:(NSInteger)value {
    return clipValue(value, [self minEVs], [self maxEVs]);
}

+ (NSInteger)validLevel:(NSInteger)level {
    return clipValue(level, [self minLevel], [self maxLevel]);
}

+ (PokemonStats *)validEVs:(PokemonStats *)stats {
    if (!stats) return nil;
    
    // Speculative initialiser, ensure PokemonStats matches this signature later.
    return [[PokemonStats alloc] initWithHP:[self clipEV:stats.hp]
                                     attack:[self clipEV:stats.attack]
                                    defense:[self clipEV:stats.defense]
                              specialAttack:[self clipEV:stats.specialAttack]
                             specialDefense:[self clipEV:stats.specialDefense]
                                      speed:[self clipEV:stats.speed]];
}

+ (NSInteger)maxMoves { return 4; }

+ (NSArray *)validMoves:(NSArray *)moves {
    if (!moves) return @[];
    // Prefix array to a max of 4 elements to mimic Swift's prefix(maxMoves)
    if (moves.count > [self maxMoves]) {
        return [moves subarrayWithRange:NSMakeRange(0, [self maxMoves])];
    }
    return moves;
}

// Convenience method to prevent array out-of-bounds crashes when binding SQLite.
- (NSString *)getMoveAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.moves.count) {
        return self.moves[index];
    }
    return @"";
}

#pragma mark - IDGeneratable Protocol

+ (NSInteger)getUniqueId {
    @synchronized (self) {
        NSInteger currentId = sNextId;
        sNextId++;
        return currentId;
    }
}

+ (void)resetIdCounterToMaximum:(NSInteger)maximum {
    @synchronized (self) {
        sNextId = maximum;
    }
}

#pragma mark - Equatable / Hashable

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[Pokemon class]]) return NO;
    
    Pokemon *other = (Pokemon *)object;
    return self.pokemonID == other.pokemonID &&
    self.pokemonNumber == other.pokemonNumber &&
    self.level == other.level &&
    [self.ability isEqualToString:other.ability] &&
    [self.nature isEqualToString:other.nature] &&
    [self.effortValues isEqual:other.effortValues] &&
    [self.moves isEqualToArray:other.moves];
}

- (NSUInteger)hash {
    // Bitwise XORing the hashes and primitives together.
    return self.pokemonID ^ self.pokemonNumber ^ self.level ^
    self.ability.hash ^ self.nature.hash ^ self.effortValues.hash ^ self.moves.hash;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    Pokemon *copy = [[[self class] allocWithZone:zone] initWithID:self.pokemonID
                                                    pokemonNumber:self.pokemonNumber
                                                            level:self.level
                                                          ability:self.ability
                                                     effortValues:self.effortValues
                                                           nature:self.nature
                                                            moves:self.moves];
    return copy;
}

@end