//
//  DatabaseController.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h> 

@class Pokemon;
@class Team;

@interface DatabaseController : NSObject

// Read-only property to check if DB opened and tables were created successfully.
@property (nonatomic, assign, readonly) BOOL success;

// Designated initialiser
- (instancetype)initWithDBName:(NSString *)dbName;

// Pokemon CRUD operations
- (NSArray *)selectAllPokemon;
- (BOOL)insertPokemon:(Pokemon *)pokemon;
- (BOOL)updatePokemon:(Pokemon *)pokemon;
- (BOOL)deletePokemonByID:(NSInteger)pokemonID;
- (BOOL)deleteAllPokemon;

// Team CRUD operations
- (NSArray *)selectAllTeams;
- (BOOL)insertTeam:(Team *)team;
- (BOOL)updateTeam:(Team *)team;
- (BOOL)deleteTeamByID:(NSInteger)teamID;
- (BOOL)deleteAllTeams;

@end
