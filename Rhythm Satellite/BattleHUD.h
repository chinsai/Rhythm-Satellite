//
//  CharacterStage.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "RSHPBar.h"

@interface BattleHUD : NSObject

//@property (nonatomic) NSArray              *hpBar;
//@property (nonatomic) NSArray              *chargeBar;

@property (nonatomic) SKLabelNode           *leftPlayerNameLabel;
@property (nonatomic) SKLabelNode           *rightPlayerNameLabel;
@property (nonatomic) RSHPBar               *leftHP;
@property (nonatomic) RSHPBar               *rightHP;
@property (nonatomic) NSArray              *chargeBar;

//UpIcon
//SIDESIcon
//DOWNIcon
@property (nonatomic) SKScene              *scene;
//ActionIcon

//update
-(void)updateHPWithLeft:(CGFloat) leftratio andRight:(CGFloat) rightratio;
-(void)setLeftName:(NSString *)name;
-(void)setRightName:(NSString *)name;

-(id)initWithScene: (SKScene *)scene;

@end
