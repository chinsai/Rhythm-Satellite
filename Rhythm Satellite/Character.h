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
#import "Action.h"

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
    NoriColorBlack
} NoriBodyColor;

@interface Character : SKSpriteNode

@property (nonatomic) uint8_t                           level;
@property (nonatomic) uint32_t                           exp;
@property (nonatomic) int32_t                           hp;
@property (nonatomic) int32_t                           maxHp;
@property (nonatomic) uint32_t                           att;
@property (nonatomic) uint32_t                           def;
@property (nonatomic) uint32_t                           money;
@property (nonatomic) uint8_t                           bodyColor;
@property (nonatomic) uint8_t                           headDeco;
@property (nonatomic) NoriAnimationState                animationState;
@property (nonatomic) BOOL                              isAnimated;
@property (nonatomic) uint8_t                           chargedEnergy;
@property (nonatomic) CGFloat                           animationSpeed;
@property (nonatomic, strong) Action                      *nextAction;
@property (nonatomic) float                             secPerBeat;



-(id)initWithLevel: (uint8_t)level withExp:(uint32_t)exp withHp:(int32_t)hp withMaxHp:(int32_t)maxHp withAtt:(uint32_t)att withDef:(uint32_t)def withMoney:(uint32_t)money;

/* Reset a character for reuse. */
- (void)resetAnimation;
- (void)resetAttributes;
- (void)takeCommand:(CommandType)command;
- (uint32_t)attack;
- (void)defendFor:(uint32_t)damage;
- (void)charge;
- (void)fireAnimationForState:(NoriAnimationState)state;
- (Action *)generateAction;
- (void)updateCharge;
- (void)compareResultFromCharacter: (Character*)character;
- (void)animateMovesWithSecondsPerBeat:(float) sec;
- (void)voiceForCommand:(CommandType)command;
- (void)dropToPositionY: (CGFloat)y ForDuration:(CGFloat)time;
- (void)riseToPositionY: (CGFloat)y ForDuration:(CGFloat)time;
- (void)turnOnSearchLight;
- (void)turnOffSearchLight;
@end
