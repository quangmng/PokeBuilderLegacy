//
//  PokemonStats.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 7/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Conforming to NSCopying is critical here so the Pokemon model can clone it safely.
@interface PokemonStats : NSObject <NSCopying>

// Unlike Team, these are read-write properties so they can be mutated after creation.
@property (nonatomic, assign) NSInteger hp;
@property (nonatomic, assign) NSInteger attack;
@property (nonatomic, assign) NSInteger defense;
@property (nonatomic, assign) NSInteger specialAttack;
@property (nonatomic, assign) NSInteger specialDefense;
@property (nonatomic, assign) NSInteger speed;

// Designated Initialiser
- (instancetype)initWithHP:(NSInteger)hp
                    attack:(NSInteger)attack
                   defense:(NSInteger)defense
             specialAttack:(NSInteger)specialAttack
            specialDefense:(NSInteger)specialDefense
                     speed:(NSInteger)speed;

// Factory methods for convenient defaults
+ (instancetype)emptyEVs;
+ (instancetype)emptyIVs;

// String-based accessors
- (void)addStatWithName:(NSString *)name value:(NSInteger)value;
- (NSInteger)getStatWithName:(NSString *)name;

@end