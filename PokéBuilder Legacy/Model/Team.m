//
//  Team.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 29/06/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "Team.h"

// Static internal counter for ID generation.
static NSInteger sNextId = 1;

// Class Extension: A private continuation of the header file.
@interface Team ()
// Private mutable backing array for pokemonIDs.
@property (nonatomic, strong) NSMutableArray *mutablePokemonIDs;
@end

@implementation Team

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
        NSArray *validIDs = [Team validPokemonList:pokemonIDs];
        _mutablePokemonIDs = [NSMutableArray arrayWithArray:validIDs];
    }
    return self;
}

#pragma mark - Accessors

- (NSArray *)pokemonIDs {
    return [_mutablePokemonIDs copy];
}

#pragma mark - Instance Methods

// Getting the Pokémon at a particular position, when less than 6 Pokémon are contained.
- (NSNumber *)pokemonIDAtIndex:(NSUInteger)index {
    if (index < self.pokemonIDs.count) {
        return [self.pokemonIDs objectAtIndex:index];
    }
    return nil;
}
// Adding Pokémon, as long as it doesn't exceed the limit.
- (void)addPokemonWithID:(NSInteger)pokemonID {
    if (self.mutablePokemonIDs.count < [Team maxPokemon]) {
        [self.mutablePokemonIDs addObject:@(pokemonID)];
    }
}

#pragma mark - Domain Logic

// Class constant, unsigned integer
+ (NSUInteger)maxPokemon {
    return 6;
}

+ (NSArray *)validPokemonList:(NSArray *)pokemonList {
    // handle nil or empty arrays safely.
    if (!pokemonList || pokemonList.count == 0) {
        return @[];
    }
    

    // Limit to only 6 Pokémon
    NSUInteger max = [Team maxPokemon];
    if (pokemonList.count <= max) {
    return pokemonList;
}
    // extracting safe
    NSRange range = NSMakeRange(0, max);
    return [pokemonList subarrayWithRange:range];

}
#pragma mark - IDGeneratable Protocol

+ (NSInteger)getUniqueId {
    @synchronized (self) { // safeguard needed to manage its state safely 
        NSInteger currentId = sNextId;
        sNextId++;
        return currentId;
    }
}
// Used when loading pre-existing SQLite data on app launch.
// Sets the runtime counter to match the highest database primary key so new teams don't cause ID clashes.
+ (void)resetIdCounterToMaximum:(NSInteger)maximum {
    @synchronized (self){
        sNextId = maximum;
    }
}

#pragma mark - Equatable / Hashable

// Required to compare two Team objects.
- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[Team class]]) return NO;
    
    Team *other = (Team *)object;
    return self.teamID == other.teamID &&
    [self.name isEqualToString:other.name] &&
    [self.pokemonIDs isEqualToArray:other.pokemonIDs];
}

- (NSUInteger)hash {
    return self.teamID ^ self.name.hash ^ self.pokemonIDs.hash;
}

#pragma mark - NSCopying
// Creating a new Team w/o modifying the og. instance
- (id)copyWithZone:(NSZone *)zone {
    Team *copy = [[[self class] allocWithZone:zone] initWithID:self.teamID
                                                          name:self.name
                                                    pokemonIDs:self.pokemonIDs];
    return copy;
}

@end