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
                      item:(NSString *)item
                     level:(NSInteger)level
                   ability:(NSString *)ability
              effortValues:(PokemonStats *)effortValues
                    nature:(NSString *)nature {
    self = [super init];
    if (self) {
        _pokemonID = pokemonID;
        _pokemonNumber = pokemonNumber;
        _item = [item copy];
        _level = [Pokemon validLevel:level];
        _ability = [ability copy];
        // Validating EVs upon initialization
        _effortValues = [Pokemon validEVs:effortValues];
        _nature = [nature copy];
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
    
    // Speculative initialiser based on the Swift code.
    // Ensure PokemonStats matches this signature later.
    return [[PokemonStats alloc] initWithHP:[self clipEV:stats.hp]
                                     attack:[self clipEV:stats.attack]
                                    defense:[self clipEV:stats.defense]
                              specialAttack:[self clipEV:stats.specialAttack]
                             specialDefense:[self clipEV:stats.specialDefense]
                                      speed:[self clipEV:stats.speed]];
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
    [self.item isEqualToString:other.item] &&
    [self.ability isEqualToString:other.ability] &&
    [self.nature isEqualToString:other.nature] &&
    [self.effortValues isEqual:other.effortValues];
}

- (NSUInteger)hash {
    // Bitwise XORing the hashes and primitives together.
    return self.pokemonID ^ self.pokemonNumber ^ self.level ^
    self.item.hash ^ self.ability.hash ^ self.nature.hash ^ self.effortValues.hash;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    Pokemon *copy = [[[self class] allocWithZone:zone] initWithID:self.pokemonID
                                                    pokemonNumber:self.pokemonNumber
                                                             item:self.item
                                                            level:self.level
                                                          ability:self.ability
                                                     effortValues:self.effortValues
                                                           nature:self.nature];
    return copy;
}

@end