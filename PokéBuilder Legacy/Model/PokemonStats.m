//
//  PokemonStats.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 7/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

// (Some comments taken from @TianLangHin's PokéCalc repo)

#import "PokemonStats.h"

@implementation PokemonStats

#pragma mark - Initialisation

// Every Pokémon has these 6 values that determine their combat behaviour and effectiveness.
- (instancetype)initWithHP:(NSInteger)hp
                    attack:(NSInteger)attack
                   defense:(NSInteger)defense
             specialAttack:(NSInteger)specialAttack
            specialDefense:(NSInteger)specialDefense
                     speed:(NSInteger)speed {
    self = [super init];
    if (self) {
        _hp = hp;
        _attack = attack;
        _defense = defense;
        _specialAttack = specialAttack;
        _specialDefense = specialDefense;
        _speed = speed;
    }
    return self;
}

#pragma mark - Factory Methods

// Convenient initialiser for effort values representations.
+ (instancetype)emptyEVs {
    return [[[self class] alloc] initWithHP:0 attack:0 defense:0 specialAttack:0 specialDefense:0 speed:0];
}

// Convenient initialiser for individual values representations.
+ (instancetype)emptyIVs {
    return [[[self class] alloc] initWithHP:31 attack:31 defense:31 specialAttack:31 specialDefense:31 speed:31];
}

#pragma mark - Programmatic Accessors

- (void)addStatWithName:(NSString *)name value:(NSInteger)value {
    // Objective-C cannot use a switch statement on strings.
    // Must use standard if/else if branches with isEqualToString:.
    if ([name isEqualToString:@"HP"]) {
        self.hp = value;
    } else if ([name isEqualToString:@"Atk"]) {
        self.attack = value;
    } else if ([name isEqualToString:@"Def"]) {
        self.defense = value;
    } else if ([name isEqualToString:@"SpA"]) {
        self.specialAttack = value;
    } else if ([name isEqualToString:@"SpD"]) {
        self.specialDefense = value;
    } else if ([name isEqualToString:@"Spe"]) {
        self.speed = value;
    }
}

 // A convenience function to extract the values of each field programmatically using a string stat name.
- (NSInteger)getStatWithName:(NSString *)name {
    if ([name isEqualToString:@"HP"]) return self.hp;
    if ([name isEqualToString:@"Atk"]) return self.attack;
    if ([name isEqualToString:@"Def"]) return self.defense;
    if ([name isEqualToString:@"SpA"]) return self.specialAttack;
    if ([name isEqualToString:@"SpD"]) return self.specialDefense;
    if ([name isEqualToString:@"Spe"]) return self.speed;
    
    return 0;
}

#pragma mark - Equatable / Hashable

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[PokemonStats class]]) return NO;
    
    PokemonStats *other = (PokemonStats *)object;
    return self.hp == other.hp &&
    self.attack == other.attack &&
    self.defense == other.defense &&
    self.specialAttack == other.specialAttack &&
    self.specialDefense == other.specialDefense &&
    self.speed == other.speed;
}

- (NSUInteger)hash {
    return self.hp ^ self.attack ^ self.defense ^ self.specialAttack ^ self.specialDefense ^ self.speed;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithHP:self.hp
                                                  attack:self.attack
                                                 defense:self.defense
                                           specialAttack:self.specialAttack
                                          specialDefense:self.specialDefense
                                                   speed:self.speed];
}

@end
