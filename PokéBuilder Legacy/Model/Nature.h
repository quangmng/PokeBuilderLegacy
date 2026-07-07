//
//  Nature.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nature : NSObject

// Returns a shared, immutable array containing all 25 Pokémon natures.
+ (NSArray *)allNatures;

// Class method to handle domain math for stat multipliers.
// statIndex expects 0 (Atk), 1 (Def), 2 (SpA), 3 (SpD), or 4 (Spe).
+ (double)multiplierForNature:(NSString *)natureName onStatIndex:(NSInteger)statIndex;

@end
