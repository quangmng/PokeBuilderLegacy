//
//  DamageCalculator.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pokemon.h"
#import "BattleDataFetcher.h"

// Replicating the Effectiveness Enum
typedef NS_ENUM(NSInteger, TypeEffectiveness) {
    TypeEffectivenessNeutral,
    TypeEffectivenessWeak,
    TypeEffectivenessResist,
    TypeEffectivenessDoubleWeak,
    TypeEffectivenessDoubleResist,
    TypeEffectivenessImmune
};

// The callback block mimicking your Tuple return
typedef void (^DamageCalculationCompletion)(double damagePercentage, TypeEffectiveness effectiveness, NSError *error);

@interface DamageCalculator : NSObject

- (void)calculateDamageForMove:(NSString *)moveName
                      attacker:(Pokemon *)attacker
                  attackerData:(BattleData *)attackerData
                      defender:(Pokemon *)defender
                  defenderData:(BattleData *)defenderData
                    completion:(DamageCalculationCompletion)completion;

@end