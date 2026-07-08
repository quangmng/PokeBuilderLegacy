//
//  TeamReader.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "TeamReader.h"

#pragma mark - Data Model Implementations

@implementation PokemonEntry
- (instancetype)init {
    self = [super init];
    if (self) {
        _species = @"";
        _level = 100;
        _nature = @"Serious";
        _effortValues = [PokemonStats emptyEVs];
        
        // IVs default to 31 in standard formats, representing emptyIVs here as a fresh slate
        _individualValues = [[PokemonStats alloc] initWithHP:31 attack:31 defense:31 specialAttack:31 specialDefense:31 speed:31];
        _moves = [NSMutableArray array];
        _gender = PokemonGenderUnknown;
    }
    return self;
}
@end

@implementation PokemonBriefData
@end

#pragma mark - TeamReader Implementation

@interface TeamReader ()
@property (nonatomic, strong) NSRegularExpression *firstLineRegex;
@property (nonatomic, strong) NSRegularExpression *statComponentRegex;
@property (nonatomic, strong) NSArray *ignoredHeaders;
@end

@implementation TeamReader

- (instancetype)init {
    self = [super init];
    if (self) {
        // Double-escaping backslashes for Objective-C string literals
        NSString *headerPattern = @"^(.+?)(?:\\s+[(]((?![MF])[A-Za-z0-9:\\- ]+|[MF][A-Za-z0-9:\\- ]+)[)])?(?:\\s+[(](M|F)[)])?(?:\\s+@\\s+(.+))?\\s*$";
        _firstLineRegex = [NSRegularExpression regularExpressionWithPattern:headerPattern options:0 error:nil];
        
        NSString *statPattern = @"\\s*(\\d+)\\s(HP|Atk|Def|SpA|SpD|Spe)\\s*";
        _statComponentRegex = [NSRegularExpression regularExpressionWithPattern:statPattern options:0 error:nil];
        
        _ignoredHeaders = @[@"Tera Type:", @"Shiny:", @"Happiness:", @"Hidden Power:", @"Dynamax Level:"];
    }
    return self;
}

- (NSArray *)readTeamFromString:(NSString *)teamString {
    // Split by newline and trim standard trailing spaces
    NSArray *rawLines = [teamString componentsSeparatedByString:@"\n"];
    NSMutableArray *team = [NSMutableArray array];
    PokemonEntry *currentPokemon = [[PokemonEntry alloc] init];
    
    for (NSString *rawLine in rawLines) {
        NSString *line = [rawLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length == 0) continue;
        
        if ([line hasPrefix:@"Ability: "]) {
            currentPokemon.ability = [line substringFromIndex:9];
        } else if ([line hasSuffix:@" Nature"]) {
            currentPokemon.nature = [line substringToIndex:line.length - 7];
        } else if ([line hasPrefix:@"Level: "]) {
            currentPokemon.level = [[line substringFromIndex:7] integerValue];
        } else if ([line hasPrefix:@"EVs: "]) {
            NSString *evs = [line substringFromIndex:5];
            NSArray *components = [evs componentsSeparatedByString:@"/"];
            for (NSString *stat in components) {
                NSTextCheckingResult *match = [self.statComponentRegex firstMatchInString:stat options:0 range:NSMakeRange(0, stat.length)];
                if (match) {
                    NSInteger val = [[stat substringWithRange:[match rangeAtIndex:1]] integerValue];
                    NSString *statName = [stat substringWithRange:[match rangeAtIndex:2]];
                    [currentPokemon.effortValues addStatWithName:statName value:val];
                }
            }
        } else if ([line hasPrefix:@"IVs: "]) {
            NSString *ivs = [line substringFromIndex:5];
            NSArray *components = [ivs componentsSeparatedByString:@"/"];
            for (NSString *stat in components) {
                NSTextCheckingResult *match = [self.statComponentRegex firstMatchInString:stat options:0 range:NSMakeRange(0, stat.length)];
                if (match) {
                    NSInteger val = [[stat substringWithRange:[match rangeAtIndex:1]] integerValue];
                    NSString *statName = [stat substringWithRange:[match rangeAtIndex:2]];
                    [currentPokemon.individualValues addStatWithName:statName value:val];
                }
            }
        } else if ([line hasPrefix:@"- "]) {
            [currentPokemon.moves addObject:[line substringFromIndex:2]];
        } else {
            // Check for ignored headers using a boolean flag
            BOOL shouldIgnore = NO;
            for (NSString *header in self.ignoredHeaders) {
                if ([line hasPrefix:header]) {
                    shouldIgnore = YES;
                    break;
                }
            }
            if (shouldIgnore) continue;
            
            // If it isn't an ignored header or a known property, it must be a new Pokemon header
            NSTextCheckingResult *match = [self.firstLineRegex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (match) {
                if (currentPokemon.species.length > 0) {
                    [team addObject:currentPokemon];
                }
                
                currentPokemon = [[PokemonEntry alloc] init];
                
                NSRange r1 = [match rangeAtIndex:1]; // Nickname or Species
                NSRange r2 = [match rangeAtIndex:2]; // Species (if Nickname is present)
                NSRange r3 = [match rangeAtIndex:3]; // Gender
                NSRange r4 = [match rangeAtIndex:4]; // Item
                
                if (r2.location != NSNotFound) {
                    currentPokemon.nickname = [line substringWithRange:r1];
                    currentPokemon.species = [line substringWithRange:r2];
                } else if (r1.location != NSNotFound) {
                    currentPokemon.species = [line substringWithRange:r1];
                }
                
                if (r3.location != NSNotFound) {
                    NSString *genderStr = [line substringWithRange:r3];
                    currentPokemon.gender = [genderStr isEqualToString:@"M"] ? PokemonGenderMale : PokemonGenderFemale;
                }
                
                if (r4.location != NSNotFound) {
                    currentPokemon.item = [line substringWithRange:r4];
                }
            }
        }
    }
    
    // Push the final Pokemon after loop finishes
    if (currentPokemon.species.length > 0) {
        [team addObject:currentPokemon];
    }
    
    return [team copy];
}

// Mimicking the `.apiGenericFormat()` string extensions from Swift
- (NSString *)formatForAPI:(NSString *)input {
    if (!input) return @"";
    NSString *lowercase = [input lowercaseString];
    return [lowercase stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

- (Pokemon *)newValidPokemonFromEntry:(PokemonEntry *)entry
                             nameData:(NSArray *)nameData
                         newPokemonID:(NSInteger)pokemonID {
    
    NSString *searchableEntry = [self formatForAPI:entry.species];
    
    PokemonBriefData *matchedData = nil;
    for (PokemonBriefData *data in nameData) {
        if ([[self formatForAPI:data.name] isEqualToString:searchableEntry]) {
            matchedData = data;
            break;
        }
    }
    
    if (!matchedData) return nil;
    
    // Format moves to API standard
    NSMutableArray *formattedMoves = [NSMutableArray array];
    for (NSString *move in entry.moves) {
        [formattedMoves addObject:[self formatForAPI:move]];
    }
    
    // Construct the strict domain model (Item, Nickname, and IVs are deliberately dropped here)
    return [[Pokemon alloc] initWithID:pokemonID
                         pokemonNumber:matchedData.apiID
                                 level:entry.level
                               ability:[self formatForAPI:entry.ability]
                          effortValues:entry.effortValues
                                nature:entry.nature
                                 moves:formattedMoves];
}

@end
