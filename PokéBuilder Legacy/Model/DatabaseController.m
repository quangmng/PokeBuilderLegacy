//
//  DatabaseController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//


#import "DatabaseController.h"
#import "Pokemon.h"
#import "PokemonStats.h"
#import "Team.h"

@interface DatabaseController () {
    // Declare raw C-pointers in the implementation block.
    sqlite3 *_db;
}
@end

@implementation DatabaseController

#pragma mark - Initialisation

- (instancetype)initWithDBName:(NSString *)dbName {
    self = [super init];
    if (self) {
        _success = NO;
        
        // Save to the Documents directory, not an App Group
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:dbName];
        
        // Open SQLite connection. Must convert NSString to a raw C-string using UTF8String.
        if (sqlite3_open([dbPath UTF8String], &_db) != SQLITE_OK) {
            return self;
        }
        
        // Pure C-string literals for schema creation (Pokémon Table)
        const char *createPokemonTable =
        "CREATE TABLE IF NOT EXISTS Pokemon ("
        "PokemonID INTEGER PRIMARY KEY, "
        "PokemonNumber INTEGER, "
        "Level INTEGER, "
        "Ability TEXT, "
        "EV_HP INTEGER, EV_Atk INTEGER, EV_Def INTEGER, EV_SpA INTEGER, EV_SpD INTEGER, EV_Spe INTEGER, "
        "Nature TEXT,"
        "Move1 TEXT, Move2 TEXT, Move3 TEXT, Move4 TEXT);";
        
        if (![self executeStandaloneSQL:createPokemonTable]) return self;
        
        // Pure C-string literals for schema creation (Teams Table)
        const char *createTeamsTable =
        "CREATE TABLE IF NOT EXISTS Teams ("
        "TeamID INTEGER NOT NULL PRIMARY KEY, "
        "TeamName TEXT NOT NULL, "
        "Pokemon1 INTEGER NULL, Pokemon2 INTEGER NULL, Pokemon3 INTEGER NULL, "
        "Pokemon4 INTEGER NULL, Pokemon5 INTEGER NULL, Pokemon6 INTEGER NULL, "
        "FOREIGN KEY(Pokemon1) REFERENCES Pokemon(PokemonID) ON DELETE SET NULL, "
        "FOREIGN KEY(Pokemon2) REFERENCES Pokemon(PokemonID) ON DELETE SET NULL, "
        "FOREIGN KEY(Pokemon3) REFERENCES Pokemon(PokemonID) ON DELETE SET NULL, "
        "FOREIGN KEY(Pokemon4) REFERENCES Pokemon(PokemonID) ON DELETE SET NULL, "
        "FOREIGN KEY(Pokemon5) REFERENCES Pokemon(PokemonID) ON DELETE SET NULL, "
        "FOREIGN KEY(Pokemon6) REFERENCES Pokemon(PokemonID) ON DELETE SET NULL);";
        
        if (![self executeStandaloneSQL:createTeamsTable]) return self;
        
        _success = YES;
    }
    return self;
}

// Helper method to accept pure const char *
- (BOOL)executeStandaloneSQL:(const char *)sql {
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        return NO;
    }
    BOOL result = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return result;
}

#pragma mark - Pokémon Queries

- (NSArray *)selectAllPokemon {
    const char *selectQuery = "SELECT * FROM Pokemon;";
    sqlite3_stmt *stmt = NULL;
    
    if (sqlite3_prepare_v2(_db, selectQuery, -1, &stmt, NULL) != SQLITE_OK) {
        return nil;
    }
    
    NSMutableArray *pokemonList = [[NSMutableArray alloc] init];
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSInteger pID = sqlite3_column_int64(stmt, 0);
        NSInteger pNum = sqlite3_column_int64(stmt, 1);
        NSInteger level = sqlite3_column_int64(stmt, 2);
        
        char *abilityC = (char *)sqlite3_column_text(stmt, 3);
        NSString *ability = abilityC ? [[NSString alloc] initWithUTF8String:abilityC] : @"";
        
        NSInteger hp = sqlite3_column_int64(stmt, 4);
        NSInteger atk = sqlite3_column_int64(stmt, 5);
        NSInteger def = sqlite3_column_int64(stmt, 6);
        NSInteger spa = sqlite3_column_int64(stmt, 7);
        NSInteger spd = sqlite3_column_int64(stmt, 8);
        NSInteger spe = sqlite3_column_int64(stmt, 9);
        
        char *natureC = (char *)sqlite3_column_text(stmt, 10);
        NSString *nature = natureC ? [[NSString alloc] initWithUTF8String:natureC] : @"";
        
        NSMutableArray *moveList = [[NSMutableArray alloc] init];
        for (int colNumber = 11; colNumber <= 14; colNumber++) {
            char *moveC = (char *)sqlite3_column_text(stmt, colNumber);
            if (moveC) {
                NSString *move = [[NSString alloc] initWithUTF8String:moveC];
                if (move.length > 0) {
                    [moveList addObject:move];
                }
            }
        }
        
        PokemonStats *stats = [[PokemonStats alloc] initWithHP:hp attack:atk defense:def specialAttack:spa specialDefense:spd speed:spe];
        Pokemon *pokemon = [[Pokemon alloc] initWithID:pID pokemonNumber:pNum level:level ability:ability effortValues:stats nature:nature moves:moveList];
        
        [pokemonList addObject:pokemon];
    }
    
    sqlite3_finalize(stmt);
    return [pokemonList copy];
}

- (BOOL)insertPokemon:(Pokemon *)pokemon {
    const char *insertQuery = "INSERT INTO Pokemon (PokemonID, PokemonNumber, Level, Ability, EV_HP, EV_Atk, EV_Def, EV_SpA, EV_SpD, EV_Spe, Nature, Move1, Move2, Move3, Move4) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, insertQuery, -1, &stmt, NULL) != SQLITE_OK) return NO;
    
    sqlite3_bind_int64(stmt, 1, pokemon.pokemonID);
    sqlite3_bind_int64(stmt, 2, pokemon.pokemonNumber);
    sqlite3_bind_int64(stmt, 3, pokemon.level);
    sqlite3_bind_text(stmt, 4, [pokemon.ability UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 5, pokemon.effortValues.hp);
    sqlite3_bind_int64(stmt, 6, pokemon.effortValues.attack);
    sqlite3_bind_int64(stmt, 7, pokemon.effortValues.defense);
    sqlite3_bind_int64(stmt, 8, pokemon.effortValues.specialAttack);
    sqlite3_bind_int64(stmt, 9, pokemon.effortValues.specialDefense);
    sqlite3_bind_int64(stmt, 10, pokemon.effortValues.speed);
    sqlite3_bind_text(stmt, 11, [pokemon.nature UTF8String], -1, SQLITE_TRANSIENT);
    // Bind moves to placeholders 12, 13, 14, 15
    for (int i = 0; i < 4; i++) {
        sqlite3_bind_text(stmt, 12 + i, [[pokemon getMoveAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
    }
    BOOL success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}
    

- (BOOL)updatePokemon:(Pokemon *)pokemon {
    const char *updateQuery = "UPDATE Pokemon SET PokemonNumber = ?, Level = ?, Ability = ?, EV_HP = ?, EV_Atk = ?, EV_Def = ?, EV_SpA = ?, EV_SpD = ?, EV_Spe = ?, Nature = ?, Move1 = ?, Move2 = ?, Move3 = ?, Move4 = ? WHERE PokemonID = ?;";
    
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, updateQuery, -1, &stmt, NULL) != SQLITE_OK) return NO;
    
    sqlite3_bind_int64(stmt, 1, pokemon.pokemonNumber);
    sqlite3_bind_int64(stmt, 2, pokemon.level);
    sqlite3_bind_text(stmt, 3, [pokemon.ability UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 4, pokemon.effortValues.hp);
    sqlite3_bind_int64(stmt, 5, pokemon.effortValues.attack);
    sqlite3_bind_int64(stmt, 6, pokemon.effortValues.defense);
    sqlite3_bind_int64(stmt, 7, pokemon.effortValues.specialAttack);
    sqlite3_bind_int64(stmt, 8, pokemon.effortValues.specialDefense);
    sqlite3_bind_int64(stmt, 9, pokemon.effortValues.speed);
    sqlite3_bind_text(stmt, 10, [pokemon.nature UTF8String], -1, SQLITE_TRANSIENT);
    
    // Bind moves to placeholders 11, 12, 13, 14
    for (int i = 0; i < 4; i++) {
        sqlite3_bind_text(stmt, 11 + i, [[pokemon getMoveAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    sqlite3_bind_int64(stmt, 15, pokemon.pokemonID);
    
    BOOL success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

- (BOOL)deletePokemonByID:(NSInteger)pokemonID {
    const char *deleteQuery = "DELETE FROM Pokemon WHERE PokemonID = ?;";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, deleteQuery, -1, &stmt, NULL) != SQLITE_OK) return NO;
    
    sqlite3_bind_int64(stmt, 1, pokemonID);
    BOOL success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

- (BOOL)deleteAllPokemon {
    const char *deleteQuery = "DELETE FROM Pokemon;";
    return [self executeStandaloneSQL:deleteQuery];
}

#pragma mark - Team Queries

- (NSArray *)selectAllTeams {
    const char *selectQuery = "SELECT * FROM Teams;";
    sqlite3_stmt *stmt = NULL;
    
    if (sqlite3_prepare_v2(_db, selectQuery, -1, &stmt, NULL) != SQLITE_OK) return nil;
    
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSInteger tID = sqlite3_column_int64(stmt, 0);
        
        char *nameC = (char *)sqlite3_column_text(stmt, 1);
        NSString *name = nameC ? [[NSString alloc] initWithUTF8String:nameC] : @"";
        
        NSMutableArray *pokemonIDs = [[NSMutableArray alloc] init];
        
        for (int colNumber = 2; colNumber <= 7; colNumber++) {
            if (sqlite3_column_type(stmt, colNumber) != SQLITE_NULL) {
                [pokemonIDs addObject:@(sqlite3_column_int64(stmt, colNumber))];
            }
        }
        
        Team *team = [[Team alloc] initWithID:tID name:name pokemonIDs:pokemonIDs];
        [teamList addObject:team];
    }
    
    sqlite3_finalize(stmt);
    return [teamList copy];
}

- (BOOL)insertTeam:(Team *)team {
    const char *insertQuery = "INSERT INTO Teams (TeamID, TeamName, Pokemon1, Pokemon2, Pokemon3, Pokemon4, Pokemon5, Pokemon6) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
    
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, insertQuery, -1, &stmt, NULL) != SQLITE_OK) return NO;
    
    sqlite3_bind_int64(stmt, 1, team.teamID);
    sqlite3_bind_text(stmt, 2, [team.name UTF8String], -1, SQLITE_TRANSIENT);
    
    for (int i = 0; i < 6; i++) {
        NSNumber *pID = [team pokemonIDAtIndex:i];
        if (pID) {
            sqlite3_bind_int64(stmt, 3 + i, [pID integerValue]);
        } else {
            sqlite3_bind_null(stmt, 3 + i);
        }
    }
    
    BOOL success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

- (BOOL)updateTeam:(Team *)team {
    const char *updateQuery = "UPDATE Teams SET TeamName = ?, Pokemon1 = ?, Pokemon2 = ?, Pokemon3 = ?, Pokemon4 = ?, Pokemon5 = ?, Pokemon6 = ? WHERE TeamID = ?;";
    
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, updateQuery, -1, &stmt, NULL) != SQLITE_OK) return NO;
    
    sqlite3_bind_text(stmt, 1, [team.name UTF8String], -1, SQLITE_TRANSIENT);
    
    for (int i = 0; i < 6; i++) {
        NSNumber *pID = [team pokemonIDAtIndex:i];
        if (pID) {
            sqlite3_bind_int64(stmt, 2 + i, [pID integerValue]);
        } else {
            sqlite3_bind_null(stmt, 2 + i);
        }
    }
    
    sqlite3_bind_int64(stmt, 8, team.teamID);
    
    BOOL success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

- (BOOL)deleteTeamByID:(NSInteger)teamID {
    const char *deleteQuery = "DELETE FROM Teams WHERE TeamID = ?;";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, deleteQuery, -1, &stmt, NULL) != SQLITE_OK) return NO;
    
    sqlite3_bind_int64(stmt, 1, teamID);
    BOOL success = (sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);
    return success;
}

- (BOOL)deleteAllTeams {
    const char *deleteQuery = "DELETE FROM Teams;";
    return [self executeStandaloneSQL:deleteQuery];
}

@end