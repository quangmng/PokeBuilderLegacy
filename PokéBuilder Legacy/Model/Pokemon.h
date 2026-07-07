//
//  Pokemon.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 6/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

// Utilising C-struct for stats. It holds primitives, lives on-stack,
// and avoids overhead of allocating a full NSObject.

typedef struct {
    NSInteger hp;
    NSInteger attack;
    NSInteger defense;
    NSInteger specialAttack;
    NSInteger specialDefense;
    NSInteger speed;
} PokemonStats;

#import <Foundation/Foundation.h>

@interface Pokemon : NSObject <NSCopying>

// Read-only to prevent accidental overwrites that would corrupt SQLite db.
@property (nonatomic, assign, readonly) NSInteger pokemonID;

// PokéAPI lookup ID. Also read-only since a Pikachu cannot suddenly become a Charizard.
@property (nonatomic, assign, readonly) NSInteger pokemonNumber;

// copy is used so if a view controller passes an NSMutableString, this object keeps an immutable snapshot, preventing background changes.
@property (nonatomic, copy) NSString *item;
@property (nonatomic, copy) NSString *ability;
@property (nonatomic, copy) NSString *nature;

@property (nonatomic, assign) NSInteger level;

// A C-struct is treated as a primitive block of memory, not an object. Hence no pointing *
@property (nonatomic, assign) PokemonStats effortValues;

// Ordered collection of NSString Pokémon moves (max 4).
@property (nonatomic, strong) NSMutableArray *moves;

// Constants
+ (NSInteger)maxLevel;
+ (NSInteger)minLevel;
+ (NSInteger)maxEVs;
+ (NSInteger)minEVs;
+ (NSInteger)maxMoves;

// Init
- (instancetype)initWithID:(NSInteger)pokemonID
             pokemonNumber:(NSInteger)pokemonNumber
                      item:(NSString *)item
                     level:(NSInteger)level
                   ability:(NSString *)ability
              effortValues:(PokemonStats)effortValues
                    nature:(NSString *)nature
                     moves:(NSArray *)moves;

// Instance methods
- (NSString *)getMoveAtIndex:(NSInteger)index;

// Domain logic/validation
+ (NSInteger)clipEV:(NSInteger)value;
+ (NSInteger)validLevel:(NSInteger)level;
+ (NSArray *)validMoves:(NSArray *)moves;
+ (PokemonStats)validEVs:(PokemonStats)stats;

// Generating ID
+ (NSInteger)getUniqueId;
+ (void)resetIdCounterToMaximum:(NSInteger)maximum;


@end
