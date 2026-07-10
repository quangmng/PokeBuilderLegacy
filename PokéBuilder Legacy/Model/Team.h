//
//  Team.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 29/06/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDGeneratable.h"

// Team inherits from NSObject and conforms to IDGeneratable
@interface Team : NSObject <IDGeneratable, NSCopying>

// Swift's `id` property becomes `teamID` because `id` is a reserved keyword in Objective-C.
@property (nonatomic, assign, readonly) NSInteger teamID;
@property (nonatomic, copy, readwrite) NSString *name;

// Exposing an immutable array to the public to prevent external modification.
@property (nonatomic, copy, readonly) NSArray *pokemonIDs;

// Designated initialiser matching your Swift properties
- (instancetype)initWithID:(NSInteger)teamID
                      name:(NSString *)name
                pokemonIDs:(NSArray *)pokemonIDs;


// Methods
- (NSNumber *)pokemonIDAtIndex:(NSUInteger)index;
- (void)addPokemonWithID:(NSInteger)pokemonID;

// Static / Class methods
+ (NSUInteger)maxPokemon;
+ (NSArray *)validPokemonList:(NSArray *)pokemonList;

@end
