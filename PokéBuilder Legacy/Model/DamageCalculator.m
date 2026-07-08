//
//  DamageCalculator.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "DamageCalculator.h"
#import "PokemonStats.h"
#import "Nature.h"

#pragma mark - Effectiveness State Machine (C-Functions)

static TypeEffectiveness addWeak(TypeEffectiveness current) {
    switch (current) {
        case TypeEffectivenessNeutral: return TypeEffectivenessWeak;
        case TypeEffectivenessWeak:
        case TypeEffectivenessDoubleWeak: return TypeEffectivenessDoubleWeak;
        case TypeEffectivenessResist: return TypeEffectivenessNeutral;
        case TypeEffectivenessDoubleResist: return TypeEffectivenessResist;
        case TypeEffectivenessImmune: return TypeEffectivenessImmune;
    }
}

static TypeEffectiveness addResist(TypeEffectiveness current) {
    switch (current) {
        case TypeEffectivenessNeutral: return TypeEffectivenessResist;
        case TypeEffectivenessResist:
        case TypeEffectivenessDoubleResist: return TypeEffectivenessDoubleResist;
        case TypeEffectivenessWeak: return TypeEffectivenessNeutral;
        case TypeEffectivenessDoubleWeak: return TypeEffectivenessWeak;
        case TypeEffectivenessImmune: return TypeEffectivenessImmune;
    }
}

static TypeEffectiveness addImmune(TypeEffectiveness current) {
    return TypeEffectivenessImmune;
}

static double multiplierForEffectiveness(TypeEffectiveness eff) {
    switch (eff) {
        case TypeEffectivenessNeutral: return 1.0;
        case TypeEffectivenessWeak: return 2.0;
        case TypeEffectivenessResist: return 0.5;
        case TypeEffectivenessDoubleWeak: return 4.0;
        case TypeEffectivenessDoubleResist: return 0.25;
        case TypeEffectivenessImmune: return 0.0;
    }
}

@implementation DamageCalculator

#pragma mark - Stat Calculations

- (PokemonStats *)battleStatsForPokemon:(Pokemon *)pokemon baseData:(BattleData *)baseData {
    PokemonStats *battleStats = [PokemonStats emptyEVs];
    
    // HP Math
    NSInteger hpBase = [baseData.stats getStatWithName:@"HP"];
    NSInteger hpEV = [pokemon.effortValues getStatWithName:@"HP"];
    NSInteger hpIntPortion = (2 * hpBase) + 31 + (hpEV / 4);
    NSInteger hpVal = ((hpIntPortion * pokemon.level) / 100) + pokemon.level + 10;
    [battleStats addStatWithName:@"HP" value:hpVal];
    
    // Other Stats
    NSArray *statNames = @[@"Atk", @"Def", @"SpA", @"SpD", @"Spe"];
    for (NSInteger i = 0; i < statNames.count; i++) {
        NSString *statName = statNames[i];
        
        // Utilising Nature class
        double natureMultiplier = [Nature multiplierForNature:pokemon.nature onStatIndex:i];
        
        NSInteger base = [baseData.stats getStatWithName:statName];
        NSInteger ev = [pokemon.effortValues getStatWithName:statName];
        
        NSInteger intPortion = (2 * base + 31 + (ev / 4)) * pokemon.level;
        NSInteger finalVal = (NSInteger)(((double)(intPortion / 100) + 5.0) * natureMultiplier);
        
        [battleStats addStatWithName:statName value:finalVal];
    }
    
    return battleStats;
}

#pragma mark - The Network Pyramid & Core Logic

- (void)calculateDamageForMove:(NSString *)moveName
                      attacker:(Pokemon *)attacker
                  attackerData:(BattleData *)attackerData
                      defender:(Pokemon *)defender
                  defenderData:(BattleData *)defenderData
                    completion:(DamageCalculationCompletion)completion {
    
    // Fetch the Move
    MoveDataFetcher *moveFetcher = [[MoveDataFetcher alloc] init];
    [moveFetcher fetchWithParameters:moveName completion:^(id moveResult, NSError *moveError) {
        
        if (moveError || !moveResult) {
            if (completion) completion(0.0, TypeEffectivenessNeutral, moveError);
            return;
        }
        
        MoveData *moveData = (MoveData *)moveResult;
        
        // Guard against non-damaging status moves
        if (!moveData.power) {
            if (completion) completion(0.0, TypeEffectivenessImmune, nil);
            return;
        }
        
        // Fetch the Type (Nested inside Move fetch)
        TypeDataFetcher *typeFetcher = [[TypeDataFetcher alloc] init];
        [typeFetcher fetchWithParameters:moveData.typeURL completion:^(id typeResult, NSError *typeError) {
            
            if (typeError || !typeResult) {
                if (completion) completion(0.0, TypeEffectivenessNeutral, typeError);
                return;
            }
            
            TypeData *typeData = (TypeData *)typeResult;
            
            // THE MATH
            
            PokemonStats *atkStats = [self battleStatsForPokemon:attacker baseData:attackerData];
            PokemonStats *defStats = [self battleStatsForPokemon:defender baseData:defenderData];
            
            BOOL isPhysical = [moveData.damageClass isEqualToString:@"physical"];
            NSInteger attackVal = isPhysical ? atkStats.attack : atkStats.specialAttack;
            
            // Body Press Edge Case
            if ([moveName isEqualToString:@"body-press"]) {
                attackVal = atkStats.defense;
            }
            
            NSInteger defenseVal = isPhysical ? defStats.defense : defStats.specialDefense;
            
            // Core Formula
            double baseDamage = (((2.0 * (double)attacker.level) / 5.0 + 2.0) * [moveData.power doubleValue] * ((double)attackVal / (double)defenseVal)) / 50.0 + 2.0;
            
            // STAB Calculation (using our NSDictionary Tuples)
            BOOL hasStab = NO;
            for (NSDictionary *typeTuple in attackerData.types) {
                if ([typeTuple[@"name"] isEqualToString:moveData.typeName]) {
                    hasStab = YES;
                    break;
                }
            }
            
            // Type Effectiveness Calculation
            TypeEffectiveness effectiveness = TypeEffectivenessNeutral;
            for (NSDictionary *defTypeTuple in defenderData.types) {
                NSString *defType = defTypeTuple[@"name"];
                if ([typeData.doubleDamageTo containsObject:defType]) {
                    effectiveness = addWeak(effectiveness);
                } else if ([typeData.halfDamageTo containsObject:defType]) {
                    effectiveness = addResist(effectiveness);
                } else if ([typeData.noDamageTo containsObject:defType]) {
                    effectiveness = addImmune(effectiveness);
                }
            }
            
            double effMultiplier = multiplierForEffectiveness(effectiveness);
            double stabMultiplier = hasStab ? 1.5 : 1.0;
            
            double finalDamage = baseDamage * stabMultiplier * effMultiplier;
            double opponentHP = (double)defStats.hp;
            
            double percentage = finalDamage / opponentHP;
            if (percentage > 1.0) percentage = 1.0; // Cap at 100%
            
            // Hand the final values back to the UI
            if (completion) completion(percentage, effectiveness, nil);
        }];
    }];
}

@end