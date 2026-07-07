//
//  PokemonStats.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 7/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

// C-STRUCT:
// Holds the 6 battle stats as primitive integers.
typedef struct {
    NSInteger hp;
    NSInteger attack;
    NSInteger defense;
    NSInteger specialAttack;
    NSInteger specialDefense;
    NSInteger speed;
} PokemonStats;

//@interface PokemonStats : NSObject

// Convenience initialisers:
// Returns a newly minted struct with predefined values.
PokemonStats PokemonStatsMakeEmptyEVs(void);
PokemonStats PokemonStatsMakeEmptyIVs(void);

// Mutation: Replaces Swift's 'mutating func'.
// CRITICAL: We pass a pointer (*stats) so the function modifies the original struct in memory.
// If didn't use *, it would modify a copy and the original would remain unchanged.
void PokemonStatsSetStat(PokemonStats *stats, NSString *name, NSInteger value);

// Extraction: Replaces Swift's 'getStat'.
// No pointer needed here because the values are being read only, not changing.
NSInteger PokemonStatsGetStat(PokemonStats stats, NSString *name);

//@end
