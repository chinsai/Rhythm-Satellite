//
//  Character.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Character.h"
#import "Command.h"

/* The different animation states of an animated character. */
typedef enum : uint8_t {
    NoriAnimationStateIdle = 0,
    NoriAnimationStateReady,
    NoriAnimationStateNod,
    NoriAnimationStateReadyNod,
    NoriAnimationStateUp,
    NoriAnimationStateSides,
    NoriAnimationStateDown,
    NoriAnimationStateSleepy,
    NoriAnimationStateSleeping,
    NoriAnimationStateAttack,
    NoriAnimationStateBlock,
    NoriAnimationStateCharge,
    NoriAnimationStateUnknown
} NoriAnimationState;

typedef enum : uint8_t {
    NoriColorWhite = 0,
    NoriColorBlack = 0
    
} NoriBodyColor;

@interface Character : SKSpriteNode

@property (nonatomic) uint8_t                           level;
@property (nonatomic) uint32_t                           exp;
@property (nonatomic) uint32_t                           hp;
@property (nonatomic) uint32_t                           maxHp;
@property (nonatomic) uint32_t                           att;
@property (nonatomic) uint32_t                           def;
@property (nonatomic) uint32_t                           money;
@property (nonatomic) uint8_t                           bodyColor;
@property (nonatomic) uint8_t                           headDeco;
@property (nonatomic) NoriAnimationState                animationState;
@property (nonatomic) BOOL                              isAnimated;
@property (nonatomic) uint8_t                           chargedEnergy;
@property (nonatomic) CGFloat                           animationSpeed;
//@property (nonatomic) Player                            *player;




-(id)initWithLevel: (uint8_t)level withExp:(uint32_t)exp withHp:(uint32_t)hp withMaxHp:(uint32_t)maxHp withAtt:(uint32_t)att withDef:(uint32_t)def withMoney:(uint32_t)money;

/* Reset a character for reuse. */
- (void)reset;

- (void)takeCommand:(CommandType)command;
- (uint32_t)attack;
- (void)defendFor:(uint32_t)damage;
- (void)charge;

- (void)fireAnimationForState:(NoriAnimationState)state;
@end
