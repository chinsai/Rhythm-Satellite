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
    
    SKLabelNode *hplabel1 = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    SKLabelNode *hplabel2 = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    hplabel1.text = @"HP: 100";
    hplabel1.fontColor = [SKColor blackColor];
    hplabel2.text = @"HP: 100";
    hplabel2.fontColor = [SKColor blackColor];
    hplabel1.fontSize = 36;
    hplabel2.fontSize = 36;
    hplabel1.position = CGPointMake(CGRectGetMidX(scene.frame)-400, CGRectGetMidY(scene.frame)+200);
    hplabel2.position = CGPointMake(CGRectGetMidX(scene.frame)+400, CGRectGetMidY(scene.frame)+200);
    [scene addChild:hplabel1];
    [scene addChild:hplabel2];
    
    SKLabelNode *chargelabel1 = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    SKLabelNode *chargelabel2 = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    chargelabel1.text = @"Charge: 0";
    chargelabel1.fontColor = [SKColor blackColor];
    chargelabel2.text = @"Charge: 0";
    chargelabel2.fontColor = [SKColor blackColor];
    chargelabel1.fontSize = 36;
    chargelabel2.fontSize = 36;
    chargelabel1.position = CGPointMake(CGRectGetMidX(scene.frame)-400, CGRectGetMidY(scene.frame)+160);
    chargelabel2.position = CGPointMake(CGRectGetMidX(scene.frame)+400, CGRectGetMidY(scene.frame)+160);
    [scene addChild:chargelabel1];
    [scene addChild:chargelabel2];

    
    
    _hpBar = [NSArray arrayWithObjects:hplabel1,hplabel2, nil];
    _chargeBar = [NSArray arrayWithObjects:chargelabel1,chargelabel2, nil];
    
    
    return self;
}

@end
