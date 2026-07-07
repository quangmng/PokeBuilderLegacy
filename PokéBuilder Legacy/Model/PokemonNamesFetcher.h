//
//  PokemonNamesFetcher.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIFetchable.h"

// Declare the data model first so the fetcher can use it.
@interface PokemonNamesData : NSObject
@property (nonatomic, assign, readonly) NSInteger speciesCount;
@property (nonatomic, copy, readonly) NSArray *names;

- (instancetype)initWithSpeciesCount:(NSInteger)speciesCount names:(NSArray *)names;
@end

// Declare the fetcher, conforming to the custom protocol.
@interface PokemonNamesFetcher : NSObject <APIFetchable>

- (NSArray *)numberListWithSpecies:(NSInteger)species total:(NSInteger)total;

@end
