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
    

    _leftHP = [[RSHPBar alloc]init];
    _rightHP = [[RSHPBar alloc]init];
    _rightHP.xScale = -1;
    _leftHP.position = CGPointMake(CGRectGetMidX(scene.frame)-300, CGRectGetMidY(scene.frame)+280);
    _rightHP.position = CGPointMake(CGRectGetMidX(scene.frame)+300, CGRectGetMidY(scene.frame)+280);
    [_scene addChild:_leftHP];
    [_scene addChild:_rightHP];
    
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
    
    
    
    return self;
}

-(void)setLeftName:(NSString *)name{
    _leftPlayerNameLabel.text = name;
}
-(void)setRightName:(NSString *)name{
    _rightPlayerNameLabel.text = name;;
}
-(void)updateHPWithLeft:(CGFloat) leftratio andRight:(CGFloat) rightratio{
    _leftHP.crop.xScale = leftratio;
    _rightHP.crop.xScale = rightratio;
}

@end
