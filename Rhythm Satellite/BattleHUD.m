//
//  CharacterStage.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "BattleHUD.h"
#import <SpriteKit/SpriteKit.h>


@implementation BattleHUD

-(id)initWithScene:(SKScene *)scene{
    self = [super init];
    _scene  = scene;
    
    //HP BAR INITIALIZATION
    _leftHP = [[RSHPBar alloc]init];
    _rightHP = [[RSHPBar alloc]init];
    _rightHP.xScale = -1;
    _leftHP.position = CGPointMake(CGRectGetMidX(scene.frame)-300, CGRectGetMidY(scene.frame)+280);
    _rightHP.position = CGPointMake(CGRectGetMidX(scene.frame)+300, CGRectGetMidY(scene.frame)+280);
    [_scene addChild:_leftHP];
    [_scene addChild:_rightHP];
    
    
    //NAME LABEL INITIALIZATION
    _leftPlayerNameLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _rightPlayerNameLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _leftPlayerNameLabel.fontColor = [SKColor colorWithRed:39.0/256 green:49.0/256 blue:79.0/256 alpha:1.0];
    _rightPlayerNameLabel.fontColor = [SKColor colorWithRed:39.0/256 green:49.0/256 blue:79.0/256 alpha:1.0];
    _leftPlayerNameLabel.fontSize = 30;
    _rightPlayerNameLabel.fontSize = 30;
    _leftPlayerNameLabel.position = CGPointMake(CGRectGetMidX(scene.frame)-480, CGRectGetMidY(scene.frame)+230);
    _rightPlayerNameLabel.position = CGPointMake(CGRectGetMidX(scene.frame)+480, CGRectGetMidY(scene.frame)+230);
    [_scene addChild:_leftPlayerNameLabel];
    [_scene addChild:_rightPlayerNameLabel];
    
    //CHARGE BAR INITIALIZATION
    _leftChargeBar  = [SKSpriteNode node];
    _rightChargeBar  = [SKSpriteNode node];
    NSArray *left = [NSArray arrayWithObjects:
                      [[RSChargeIcon alloc]init],
                      [[RSChargeIcon alloc]init],
                      [[RSChargeIcon alloc]init],
                      [[RSChargeIcon alloc]init],nil];
    NSArray *right = [NSArray arrayWithObjects:
                      [[RSChargeIcon alloc]init],
                      [[RSChargeIcon alloc]init],
                      [[RSChargeIcon alloc]init],
                      [[RSChargeIcon alloc]init],nil];
    for (int i = 0; i<4 ; i++) {
        RSChargeIcon* l = left[i];
        RSChargeIcon* r = right[i];
        l.position = CGPointMake( -( (l.size.width+10.0)*3/2 ) + (l.size.width+10.0)*i, 0.0 );
        r.position = CGPointMake( -( (l.size.width+10.0)*3/2 ) + (l.size.width+10.0)*(3-i), 0.0 );
        [_leftChargeBar addChild:l];
        [_rightChargeBar addChild:r];
    }
    
    [_scene addChild:_leftChargeBar];
    [_scene addChild:_rightChargeBar];
    
    _leftChargeBar.position = CGPointMake(CGRectGetMidX(scene.frame)-300, CGRectGetMidY(scene.frame)-290);
    _rightChargeBar.position = CGPointMake(CGRectGetMidX(scene.frame)+300, CGRectGetMidY(scene.frame)-290);
    
    //ROUNDS LEFT INITIALIZATION
    _roundBoard = [SKSpriteNode spriteNodeWithImageNamed:@"round"];
    _roundBoard.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMidY(scene.frame)+285);
    _roundLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _roundLabel.fontColor = [SKColor whiteColor];
    _roundLabel.fontSize = 30;
    _roundLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMidY(scene.frame)+260);
    [_scene addChild:_roundBoard];
    [_scene addChild:_roundLabel];
    
    
    return self;
}

-(void)setLeftName:(NSString *)name{
    _leftPlayerNameLabel.text = name;
}
-(void)setRightName:(NSString *)name{
    _rightPlayerNameLabel.text = name;;
}
-(void)updateHPWithLeft:(CGFloat) leftratio andRight:(CGFloat) rightratio{
    _leftHP.crop.maskNode.xScale = leftratio;
    _rightHP.crop.maskNode.xScale = rightratio;
}

-(void)chargeWithCharacterLeft:(Character*)character{
    NSArray *allChildren = [_leftChargeBar children];
    RSChargeIcon *target = allChildren[character.chargedEnergy];
    [target charge];
}

-(void)chargeWithCharacterRight:(Character*)character{
    NSArray *allChildren = [_rightChargeBar children];
    RSChargeIcon *target = allChildren[character.chargedEnergy];
    [target charge];
}

-(void)dischargeWithCharacterLeft:(Character*)character{
    NSArray *allChildren = [_leftChargeBar children];
    RSChargeIcon *target = allChildren[character.chargedEnergy+1];
    [target discharge];
}

-(void)dischargeWithCharacterRight:(Character*)character{
    NSArray *allChildren = [_rightChargeBar children];
    RSChargeIcon *target = allChildren[character.chargedEnergy+1];
    [target discharge];
}

-(void)updateChargeOfLeftCharacter:(Character*)character{
    int currentCharge = character.chargedEnergy;
    NSArray *allChildren = [_leftChargeBar children];
    int lastCharge = 0;
    for (int i = 0 ; i < 4 ; i++){
        if( ((RSChargeIcon *)allChildren[i]).charged ){
            lastCharge = i+1;
        }
        else{
            break;
        }
    }
        
    //no change
    if (lastCharge == currentCharge) {
        return;
    }
    //decreased
    else if(lastCharge > currentCharge){
        [((RSChargeIcon *)allChildren[lastCharge-1]) discharge];
    }
    //increase
    else{
        [((RSChargeIcon *)allChildren[currentCharge-1]) charge];
    }
}

-(void)updateChargeOfRightCharacter:(Character*)character{
    int currentCharge = character.chargedEnergy;
    NSArray *allChildren = [_rightChargeBar children];
    int lastCharge = 0;
    for (int i = 0 ; i < 4 ; i++){
        if( ((RSChargeIcon *)allChildren[i]).charged ){
            lastCharge =i+1;
        }
        else{
            break;
        }
    }
    //comparing number of charge
    if (lastCharge == currentCharge) {
        return;
    }
    else if(lastCharge > currentCharge){
        [((RSChargeIcon *)allChildren[lastCharge-1]) discharge];
    }
    else{
        [((RSChargeIcon *)allChildren[currentCharge-1]) charge];
    }
}
-(void)resetAll{
    _leftHP.crop.maskNode.xScale = 1.0;
    _rightHP.crop.maskNode.xScale = 1.0;
    for (RSChargeIcon *l in [_leftChargeBar children]) {
        [l discharge];
    }
    for (RSChargeIcon *r in [_rightChargeBar children]) {
        [r discharge];
    }
    _roundLabel.text = @"00";
}
-(void)setRound:(int)round{
    _roundLabel.text = [NSString stringWithFormat:@"%02d", round];
}
@end
