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

#import <UIKit/UIKit.h>

@interface Pokemon : NSObject <NSCopying>

// Read-only to prevent accidental overwrites that would corrupt SQLite linkage.
@property (nonatomic, assign, readonly) NSInteger pokemonID;


@end
