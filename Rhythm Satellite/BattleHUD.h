//
//  CharacterStage.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "RSHPBar.h"
#import "RSChargeIcon.h"
#import "Character.h"

@interface BattleHUD : NSObject

@property (nonatomic) SKLabelNode           *leftPlayerNameLabel;
@property (nonatomic) SKLabelNode           *rightPlayerNameLabel;
@property (nonatomic) RSHPBar               *leftHP;
@property (nonatomic) RSHPBar               *rightHP;
@property (nonatomic) SKSpriteNode          *leftChargeBar;
@property (nonatomic) SKSpriteNode          *rightChargeBar;
@property (nonatomic) SKSpriteNode          *roundBoard;
@property (nonatomic) SKLabelNode           *roundLabel;


//UpIcon
//SIDESIcon
//DOWNIcon
@property (nonatomic) SKScene              *scene;
//ActionIcon

-(id)initWithScene: (SKScene *)scene;

//update
-(void)updateHPWithLeft:(CGFloat) leftratio andRight:(CGFloat) rightratio;
-(void)setLeftName:(NSString *)name;
-(void)setRightName:(NSString *)name;
-(void)setRound:(int)round;
-(void)chargeWithCharacterLeft:(Character*)character;
-(void)chargeWithCharacterRight:(Character*)character;
-(void)updateChargeOfLeftCharacter:(Character*)character;
-(void)updateChargeOfRightCharacter:(Character*)character;
-(void)resetAll;

@end
