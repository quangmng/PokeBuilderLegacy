//
//  BattleDataFetcher.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetchable.h"

@class PokemonStats;

#pragma mark - BattleData Model

@interface BattleData : NSObject

@property (nonatomic, copy, readonly) NSArray *abilities; // Array of NSStrings
@property (nonatomic, strong, readonly) PokemonStats *stats;
@property (nonatomic, copy, readonly) NSArray *types;     // Array of NSDictionaries (Name and URL)

- (instancetype)initWithAbilities:(NSArray *)abilities
                            stats:(PokemonStats *)stats
                            types:(NSArray *)types;

@end


#pragma mark - BattleDataFetcher

@interface BattleDataFetcher : NSObject <APIFetchable>

// No extra methods needed in the header; the protocol handles the contract!

@end
