//
//  TeamReader.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "Pokemon.h"
#import "PokemonStats.h"

#pragma mark - Extensibility Data Models

typedef NS_ENUM(NSInteger, PokemonGender) {
    PokemonGenderUnknown,
    PokemonGenderMale,
    PokemonGenderFemale
};

@interface PokemonEntry : NSObject
@property (nonatomic, copy) NSString *species;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, assign) PokemonGender gender;
@property (nonatomic, copy) NSString *item;
@property (nonatomic, copy) NSString *ability;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) PokemonStats *effortValues;
@property (nonatomic, strong) PokemonStats *individualValues;
@property (nonatomic, copy) NSString *nature;
@property (nonatomic, strong) NSMutableArray *moves; // Array of NSStrings
@end

@interface PokemonBriefData : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger apiID;
@end

#pragma mark - TeamReader

@interface TeamReader : NSObject

- (NSArray *)readTeamFromString:(NSString *)teamString;
- (Pokemon *)newValidPokemonFromEntry:(PokemonEntry *)entry
                             nameData:(NSArray *)nameData
                         newPokemonID:(NSInteger)pokemonID;

@end
