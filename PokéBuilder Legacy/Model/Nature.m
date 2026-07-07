//
//  Nature.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "Nature.h"

@implementation Nature

// Returns a shared, immutable array containing all 25 Pokémon natures.
+ (NSArray *)allNatures{
    // Declare a static variable to hold the array across multiple method calls.
    static NSArray *sNatures = nil;
    
    // Declare a static token to track whether the initialisation has happened yet.
    static dispatch_once_t onceToken;
    
    // Execute the block exactly once for the entire lifetime of the app. 
    dispatch_once(&onceToken, ^{
        sNatures = @[
                     @"Hardy", @"Lonely", @"Adamant", @"Naughty", @"Brave",
                     @"Bold", @"Docile", @"Impish", @"Lax", @"Relaxed",
                     @"Modest", @"Mild", @"Bashful", @"Rash", @"Quiet",
                     @"Calm", @"Gentle", @"Careful", @"Quirky", @"Sassy",
                     @"Timid", @"Hasty", @"Jolly", @"Naive", @"Serious"
                     ];
    });
    
    return sNatures;
}

+ (double)multiplierForNature:(NSString *)natureName onStatIndex:(NSInteger)statIndex {
    NSArray *natures = [self allNatures];
    
    // Equivalent to Swift's firstIndex(of:)
    NSUInteger natureIndex = [natures indexOfObject:natureName];
    
    // If the nature isn't found, return a neutral 1.0 multiplier
    if (natureIndex == NSNotFound) {
        return 1.0;
    }
    
    // The core math logic from your Swift file
    NSInteger enhance = natureIndex / 5;
    NSInteger reduce = natureIndex % 5;
    
    if (enhance == reduce) {
        return 1.0;
    }
    
    if (statIndex == enhance) {
        return 1.1; // 10% Boost
    } else if (statIndex == reduce) {
        return 0.9; // 10% Reduction
    }
    
    return 1.0;
}

@end
