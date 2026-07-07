//
//  NSString+Formatting.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//
// (Comments taken from @DuongAnhTran in @TianLangHin's PokéCalc repo)


#import "NSString+Formatting.h"

@implementation NSString (Formatting)

- (NSString *)readableFormat {
    // Split the string by "-"
    NSArray *components = [self componentsSeparatedByString:@"-"];
    
    // Obj-C doesn't have `.map` , a mutable array and a for-in loop are used.
    NSMutableArray *capitalizedComponents = [NSMutableArray arrayWithCapacity:components.count];
    for (NSString *component in components) {
        [capitalizedComponents addObject:[component capitalizedString]];
    }
    
    // Join the array back together with spaces
    NSString *baseString = [capitalizedComponents componentsJoinedByString:@" "];
    
    // Handle the specific " Mask" suffix removal
    if ([baseString hasSuffix:@" Mask"]) {
        // substringToIndex: takes the first X characters up to the index.
        return [baseString substringToIndex:baseString.length - 5];
    }
    
    return baseString;
}

// Converts strings representing Pokémon from either
// a human-readable format or PokéPaste format into the PokéAPI format.
- (NSString *)apiPokemonFormat {
    // Method chaining isn't a thing in Objective-C, so we reassign the variable sequentially.
    NSString *baseString = [self lowercaseString];
    
    // Trimming whitespaces uses NSCharacterSet
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    baseString = [baseString stringByTrimmingCharactersInSet:whitespaces];
    
    // Generally, this conversion involves converting capitalised space-separated words into Kebab-case.
    baseString = [baseString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    baseString = [baseString stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    // However, some specific Pokémon have extra logic required for this conversion
    // due to the convention of PokéAPI.
    if ([baseString hasPrefix:@"ogerpon-"]) {
        return [baseString stringByAppendingString:@"-mask"];
    } else if ([baseString hasPrefix:@"indeedee-m"]) {
        return @"indeedee-male";
    } else if ([baseString hasPrefix:@"indeedee-f"]) {
        return @"indeedee-female";
    } else if ([baseString hasPrefix:@"arceus"]) {
        return @"arceus";
    } else if ([baseString hasPrefix:@"silvally"]) {
        return @"silvally";
    } else if ([baseString hasPrefix:@"necrozma-dusk-mane"]) {
        return @"necrozma-dusk";
    } else if ([baseString hasPrefix:@"necrozma-dawn-mane"]) {
        return @"necrozma-dawn";
    } else if ([baseString hasPrefix:@"basculegion"]) {
        return @"basculegion-male";
    }
    
    return baseString;
}
// Converts all strings except those representing Pokémon from a human-readable format
// into the PokéAPI format. This is used for items, abilities and moves. (probs only abilities lol)
- (NSString *)apiGenericFormat {
    // Similar conversion to Kebab-case, with the added logic of removing apostrophes and brackets.
    NSString *baseString = [self lowercaseString];
    baseString = [baseString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    baseString = [baseString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    baseString = [baseString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    baseString = [baseString stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    return baseString;
}


@end
