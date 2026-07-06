//
//  Team.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 29/06/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Team : NSObject <NSCopying>

// readonly for values meant to be immutable, strong/assign for others
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign, readonly) NSInteger teamID;
@property (nonatomic, strong) NSMutableArray *pokemonIDs;

// Class constant
+ (NSInteger)maxPokemon;

// Initialise
- (instancetype)initWithID:(NSInteger)teamID name:(NSString *)name pokemonIDs:(NSArray *)pokemonIDs;

// Instance Methods
- (NSNumber *)getPokemonIDAtIndex:(NSInteger)index; // Returns NSNumber or nil if empty
- (void)addPokemonWithID:(NSInteger)pokemonID; 

// Protocol Conformance
+ (NSInteger)getUniqueId;
+ (void)resetIdCounterToMaximum:(NSInteger)maximum;

// Domain Logic
+ (NSArray *)validPokemon:(NSArray *)pokemonList;
 
@end
