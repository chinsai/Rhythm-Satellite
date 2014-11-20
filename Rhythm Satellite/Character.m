//
//  Character.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Character.h"
#import "Command.h"

#define nodFrames 2
#define movementFrames 4

@implementation Character


NSArray *nodAnimationFrames = nil;
NSArray *readyNodAnimationFrames = nil;
NSArray *upAnimationFrames = nil;
NSArray *downAnimationFrames = nil;
NSArray *sidesAnimationFrames = nil;

-(id)initWithLevel: (uint8_t)level withExp:(uint32_t)exp withHp:(int32_t)hp withMaxHp:(int32_t)maxHp withAtt:(uint32_t)att withDef:(uint32_t)def withMoney:(uint32_t)money{
    
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


- (void)resetAnimation{
    [self fireAnimationForState:NoriAnimationStateIdle];;
}

- (void)resetAttributes{
    _hp = _maxHp;
    _chargedEnergy = 0;
}

- (void)takeCommand:(CommandType)command{
    [self voiceForCommand:command];
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
    _chargedEnergy--;
    return _att;
}
- (void)defendFor:(uint32_t)damage{
    _hp=_hp-(damage-_def);
}

- (void)charge{
    _chargedEnergy++;
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


- (Action *)generateAction{
    if (!_nextAction) {
        _nextAction = [[Action alloc]initWithRandomAction];
    }else{
        [_nextAction randomAction];
    }
    while (_nextAction.actionType == ATTACK && _chargedEnergy == 0) {
        [_nextAction randomAction];
    }
    while (_nextAction.actionType == CHARGE && _chargedEnergy == 4) {
        [_nextAction randomAction];
    }
    
    [self updateCharge];
    NSLog(@"%@", [_nextAction toString]);
    return _nextAction;
}

-(void)updateCharge{
    switch (_nextAction.actionType) {
        case ATTACK:
            if (_chargedEnergy == 0) {
                [_nextAction setActionWithType:NONE];
                return;
            }
            _chargedEnergy--;
            break;
        case CHARGE:
            if(_chargedEnergy == 4){
                return;
            }
            _chargedEnergy++;
            break;
        default:
            break;
    }
}

-(void)animateMovesWithSecondsPerBeat:(float) sec{
    if (!_nextAction){
        return;
    }
    NSArray *temp =_nextAction.commands;
    [self runAction:[SKAction sequence:@[
                                         [SKAction runBlock:^(void){[self takeCommand:((Command*)temp[0]).input];}],
                                         [SKAction waitForDuration: sec],
                                         [SKAction runBlock:^(void){[self takeCommand:((Command*)temp[1]).input];}],
                                         [SKAction waitForDuration: sec],
                                         [SKAction runBlock:^(void){[self takeCommand:((Command*)temp[2]).input];}],
                                         [SKAction waitForDuration: sec],
                                         [SKAction runBlock:^(void){[self takeCommand:((Command*)temp[3]).input];}]
                                         ]]];
}

- (void)compareResultFromCharacter: (Character*)character{
    
    switch (character.nextAction.actionType) {
        case ATTACK:
            if(!_nextAction){
                _hp = _hp-character.att;
            }
            else if(_nextAction.actionType == BLOCK){
                _hp = _hp - (character.att-_def);
            }
            else if(_nextAction.actionType == ATTACK){
                ;
            }
            else{
                _hp = _hp-character.att;
            }
            break;
        case BLOCK:
            if(_nextAction.actionType == ATTACK){
                character.hp = character.hp - (_att-character.def);
            }
            break;
        case CHARGE:
            if(_nextAction.actionType == ATTACK){
                character.hp = character.hp - _att;
            }
            break;
        default:
            break;
    }
    if(_hp < 0){
        _hp = 0;
    }
    if(character.hp <0){
        character.hp = 0;
    }
}


- (NSArray *) loadFramesFromAtlas:(NSString *)atlasName withBaseFile:(NSString *)baseFileName Frames:(int) numberOfFrames {
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    for (int i = 1; i <= numberOfFrames; i++) {
        //todo fix the sequence of the animation
        NSString *fileName = [NSString stringWithFormat:@"%@%04d", baseFileName, numberOfFrames+1-i];
        SKTexture *texture = [atlas textureNamed:fileName];
        [frames addObject:texture];
    }
    
    return frames;
}

-(void)voiceForCommand:(CommandType)command{
    switch (command) {
        case UP:
            [self runAction:[SKAction playSoundFileNamed:@"a.wav" waitForCompletion:NO]];
            break;
        case DOWN:
            [self runAction:[SKAction playSoundFileNamed:@"da.wav" waitForCompletion:NO]];
            break;
        case SIDES:
            [self runAction:[SKAction playSoundFileNamed:@"sa.wav" waitForCompletion:NO]];
            break;
        default:
            break;
    }
}

- (void)dropToPositionY: (CGFloat)y ForDuration:(CGFloat)time{
    if (y > self.position.y)
        return;
    
    SKAction *drop = [SKAction moveToY:y duration:time];
    drop.timingMode = SKActionTimingEaseOut;
    [self runAction:drop];
}

- (void)riseToPositionY: (CGFloat)y ForDuration:(CGFloat)time{
//    NSLog(@"%f %f", y, self.position.y );
    if(y < self.position.y)
        return;
    SKAction *rise = [SKAction moveToY:y duration:time];
    rise.timingMode = SKActionTimingEaseOut;
    [self runAction:rise];
    NSLog(@"rise");
}


@end
