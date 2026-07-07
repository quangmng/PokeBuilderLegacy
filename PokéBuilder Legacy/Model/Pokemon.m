//
//  Pokemon.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 6/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "Pokemon.h"

// The runtime counter ensuring each new Pokemon gets a unique primary key before hitting the DB.
static NSInteger _nextId = 1;

@implementation Pokemon

#pragma mark - Constants

+ (NSInteger)maxLevel{
    return 100;
}
+ (NSInteger)minLevel{
    return 1;
}
+ (NSInteger)maxEVs{
    return 252;
}
+ (NSInteger)minEVs{
    return 0;
}
+ (NSInteger)maxMoves{
    return 4;
}

#pragma mark - Initialisation

- (instancetype)initWithID:(NSInteger)pokemonID
             pokemonNumber:(NSInteger)pokemonNumber
                      item:(NSString *)item
                     level:(NSInteger)level
                   ability:(NSString *)ability
              effortValues:(PokemonStats)effortValues
                    nature:(NSString *)nature
                     moves:(NSArray *)moves {
    self = [super init];
    if (self) {
        // Direct assignment to bypass public readonly restrictions
        _pokemonID = pokemonID;
        _pokemonNumber = pokemonNumber;
        
        // Guard against NSMutableString hijacking by explicitly copying the inputs
        _item = [item copy];
        _ability = [ability copy];
        _nature = [nature copy];
        
        // Pass integers and structs through our class validation filters before storing them
        _level = [Pokemon validLevel:level];
        _effortValues = [Pokemon validEVs:effortValues];
        
        // Caps to 4 moves, then store as mutable
        NSArray *validatedMoves = [Pokemon validMoves:moves];
        _moves = [[NSMutableArray alloc] initWithArray:validatedMoves];
    }
    return self;
}

#pragma mark - Instance Methods

- (NSString *)getMoveAtIndex:(NSInteger)index {
    // Guard against NSRangeException crashes. If UI asks for move index 3
    // but Pokemon only has 2 moves, this safely catches it and returns an empty string.
    if (index >= 0 && index < self.moves.count) {
        return [self.moves objectAtIndex:index];
    }
    return @"";
}

#pragma mark - Private Clipping Helper

// STATIC C-FUNCTION:
// - Runs instantly without Obj-C message-lookup overhead.
// - 'static' hides it from other files to prevent duplicate-name crashes.
// - Math: MIN(MAX(value, lowest), highest) forces a number to stay within limits.
static NSInteger clip(NSInteger value, NSInteger lowerBound, NSInteger upperBound) {
    return MIN(MAX(value, lowerBound), upperBound);
}

#pragma mark - Domain Logic & Validation


+ (NSInteger)clipEV:(NSInteger)value {
    return clip(value, [Pokemon minEVs], [Pokemon maxEVs]);
}

+ (NSInteger)validLevel:(NSInteger)level {
    return clip(level, [Pokemon minLevel], [Pokemon maxLevel]);
}

+ (NSArray *)validMoves:(NSArray *)moves {
    if (!moves || moves.count == 0) return @[];
    
    NSInteger maxCount = [Pokemon maxMoves];
    if (moves.count <= maxCount) return moves;
    
    // Cap arrays larger than 4, discarding excess elements to prevent UI crashes.
    return [moves subarrayWithRange:NSMakeRange(0, maxCount)];
}

+ (PokemonStats)validEVs:(PokemonStats)stats {
    // Creates a new C-struct on the stack, assigns clamped values, and returns it.
    PokemonStats validatedStats;
    validatedStats.hp             = [Pokemon clipEV:stats.hp];
    validatedStats.attack         = [Pokemon clipEV:stats.attack];
    validatedStats.defense        = [Pokemon clipEV:stats.defense];
    validatedStats.specialAttack  = [Pokemon clipEV:stats.specialAttack];
    validatedStats.specialDefense = [Pokemon clipEV:stats.specialDefense];
    validatedStats.speed          = [Pokemon clipEV:stats.speed];
    
    return validatedStats;
}

#pragma mark - ID Generation

+ (NSInteger)getUniqueId {
    NSInteger currentId = _nextId;
    _nextId++;
    return currentId;
}

+ (void)resetIdCounterToMaximum:(NSInteger)maximum {
    // Syncs the runtime counter to the highest SQLite primary key on app launch.
    _nextId = maximum;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    // Standard protocol requirement to duplicate this object into a new memory space.
    Pokemon *copy = [[[self class] allocWithZone:zone] initWithID:self.pokemonID
                                                    pokemonNumber:self.pokemonNumber
                                                             item:self.item
                                                            level:self.level
                                                          ability:self.ability
                                                     effortValues:self.effortValues
                                                           nature:self.nature
                                                            moves:self.moves];
    return copy;
}


@end
