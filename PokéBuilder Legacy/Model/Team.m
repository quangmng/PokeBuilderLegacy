//
//  Team.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 29/06/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "Team.h"

static NSInteger _nextId = 1;

@implementation Team

// Class constant
+ (NSInteger)maxPokemon {
    return 6;
}

#pragma mark - Initialisation

// Initialising
- (instancetype)initWithID:(NSInteger)teamID name:(NSString *)name pokemonIDs:(NSArray *)pokemonIDs {
    self = [super init];
    if (self) {
        // Modifying the ID directly
        _teamID = teamID;
        // Get copy of name in case of accidental edit somewhere
        _name = [name copy];
        // Caps incoming array at 6 Pokémon, copies to mutable array for append/remove
        NSArray *validated = [Team validPokemon:pokemonIDs];
        _pokemonIDs = [[NSMutableArray alloc] initWithArray:validated];
    }
    return self;
}

#pragma mark - Convenience Operations

// Getting the Pokémon at a particular position, when less than 6 Pokémon are contained.
- (NSNumber *)getPokemonIDAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.pokemonIDs.count) {
        return [self.pokemonIDs objectAtIndex:index];
    }
    return nil;
}
// Adding Pokémon, as long as it doesn't exceed the limit.
- (void)addPokemonWithID:(NSInteger)pokemonID {
    if (self.pokemonIDs.count < [Team maxPokemon]) {
        [self.pokemonIDs addObject:[NSNumber numberWithInteger:pokemonID]];
    }
}

#pragma mark - ID Generation

+ (NSInteger)getUniqueId {
    NSInteger currentId = _nextId;
    _nextId++; // Increment the teamID
    return currentId;
}

// Used when loading pre-existing SQLite data on app launch.
// Sets the runtime counter to match the highest database primary key so new teams don't cause ID clashes.
+ (void)resetIdCounterToMaximum:(NSInteger)maximum {
    _nextId = maximum;
}

+ (NSArray *)validPokemon:(NSArray *)pokemonList {
    // Dealing with uninitiallised arrays
    if (!pokemonList || pokemonList.count == 0) {
        return @[];
    }
    
    // Limit to only 6 Pokémon
    NSInteger maxCount = [Team maxPokemon];
    if (pokemonList.count <= maxCount) {
        return pokemonList;
    }
    // Only keeping 6 moves per Pokémon list
    NSRange range = NSMakeRange(0, maxCount);
    return [pokemonList subarrayWithRange:range];
}

// Creating a new Team w/o modifying the og. instance
- (id)copyWithZone:(NSZone *)zone {
    Team *copy = [[[self class] allocWithZone:zone] initWithID:self.teamID
                                                          name:self.name
                                                    pokemonIDs:self.pokemonIDs];
    return copy;
}

@end