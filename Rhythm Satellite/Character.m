//
//  Character.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Character.h"


#define nodFrames 2
#define movementFrames 4

@implementation Character


NSArray *nodAnimationFrames = nil;
NSArray *readyNodAnimationFrames = nil;
NSArray *upAnimationFrames = nil;
NSArray *downAnimationFrames = nil;
NSArray *sidesAnimationFrames = nil;

-(id)initWithLevel: (uint8_t)level withExp:(uint32_t)exp withHp:(uint32_t)hp withMaxHp:(uint32_t)maxHp withAtt:(uint32_t)att withDef:(uint32_t)def withMoney:(uint32_t)money{
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Nori_Nod"];
    SKTexture *texture = [atlas textureNamed:@"nori_nod_0001"];
    self = [super initWithTexture:texture];
    
    nodAnimationFrames = [self loadFramesFromAtlas:@"Nori_Nod" withBaseFile:@"nori_nod_" Frames:nodFrames];
    readyNodAnimationFrames = [self loadFramesFromAtlas:@"Nori_Ready_Nod" withBaseFile:@"nori_ready_nod_" Frames:nodFrames];
    upAnimationFrames = [self loadFramesFromAtlas:@"Nori_Up" withBaseFile:@"nori_up_" Frames:movementFrames];
    downAnimationFrames = [self loadFramesFromAtlas:@"Nori_Down" withBaseFile:@"nori_down_" Frames:movementFrames];
    sidesAnimationFrames = [self loadFramesFromAtlas:@"Nori_Sides" withBaseFile:@"nori_sides_" Frames:movementFrames];
    
    
    _level = level;
    _exp = exp;
    _hp = hp;
    _maxHp = maxHp;
    _att = att;
    _def = def;
    _money = money;
    _animationState = NoriAnimationStateIdle;
    _isAnimated = NO;
    _bodyColor = NoriColorWhite;
    _chargedEnergy = 0;
    _animationSpeed = 1.0f/20.0f;;
    _nextAction = nil;
    
    
    return self;
}


- (void)reset{
    [self fireAnimationForState:NoriAnimationStateIdle];;
}

- (void)takeCommand:(CommandType)command{
    switch (command) {
        case UP:
            [self fireAnimationForState:NoriAnimationStateUp];
            break;
        case DOWN:
            [self fireAnimationForState:NoriAnimationStateDown];
            break;
        case SIDES:
            [self fireAnimationForState:NoriAnimationStateSides];
            break;
        default:
            break;
    };
}

- (uint32_t)attack{
    ;
    return _att;
}
- (void)defendFor:(uint32_t)damage{
    ;
}

- (void)charge{
    
}

- (void)fireAnimationForState:(NoriAnimationState)state{
    if (_isAnimated) {
        return;
    }
    
    _isAnimated = YES;
    
    switch (state) {
        case NoriAnimationStateNod:
            if (_animationState == NoriAnimationStateIdle) {
                _animationState = state;
                [self runAction:[SKAction sequence:@[
                                                     [SKAction animateWithTextures:nodAnimationFrames timePerFrame:self.animationSpeed resize:YES restore:YES],
                                                     [SKAction runBlock:^{
                    _isAnimated = NO;
                    _animationState = NoriAnimationStateIdle;
                }]]]];
            }
            break;
        case NoriAnimationStateReadyNod:
            if (_animationState == NoriAnimationStateReady) {
                _animationState = state;
                [self runAction:[SKAction sequence:@[
                                                     [SKAction animateWithTextures:readyNodAnimationFrames timePerFrame:self.animationSpeed resize:YES restore:YES],
                                                     [SKAction runBlock:^{
                    _isAnimated = NO;
                    _animationState = NoriAnimationStateReady;
                }]]]];
            }
            break;
        case NoriAnimationStateUp:
            if (_animationState == NoriAnimationStateReady) {
                _animationState = state;
                [self runAction:[SKAction sequence:@[
                                                     [SKAction animateWithTextures:upAnimationFrames timePerFrame:self.animationSpeed resize:YES restore:YES],
                                                     [SKAction runBlock:^{
                    _isAnimated = NO;
                    _animationState = NoriAnimationStateReady;
                }]]]];
            }
            break;
        case NoriAnimationStateDown:
            if (_animationState == NoriAnimationStateReady) {
                _animationState = state;
                [self runAction:[SKAction sequence:@[
                                                     [SKAction animateWithTextures:downAnimationFrames timePerFrame:self.animationSpeed resize:YES restore:YES],
                                                     [SKAction runBlock:^{
                    _isAnimated = NO;
                    _animationState = NoriAnimationStateReady;
                }]]]];
            }
            break;
        
        case NoriAnimationStateSides:
            if (_animationState == NoriAnimationStateReady) {
                _animationState = state;
                [self runAction:[SKAction sequence:@[
                                                     [SKAction animateWithTextures:sidesAnimationFrames timePerFrame:self.animationSpeed resize:YES restore:YES],
                                                     [SKAction runBlock:^{
                    _isAnimated = NO;
                    _animationState = NoriAnimationStateReady;
                }]]]];
            }
            break;
        case NoriAnimationStateIdle:
            [self setTexture:[[SKTextureAtlas atlasNamed:@"Nori_Nod"] textureNamed:@"nori_nod_0001"]];
            _isAnimated = NO;
            _animationState = state;
            break;
        case NoriAnimationStateReady:
            [self setTexture:[[SKTextureAtlas atlasNamed:@"Nori_Ready_Nod"] textureNamed:@"nori_ready_nod_0001"]];
            _isAnimated = NO;
            _animationState = state;
            break;
        default:
            _isAnimated = NO;
            break;
    }
    
    
    
}


- (NSArray *) loadFramesFromAtlas:(NSString *)atlasName withBaseFile:(NSString *)baseFileName Frames:(int) numberOfFrames {
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    for (int i = 1; i <= numberOfFrames; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%04d.png", baseFileName, i];
        SKTexture *texture = [atlas textureNamed:fileName];
        [frames addObject:texture];
    }
    
    return frames;
}

@end
