//
//  CharacterStage.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BattleHUD : NSObject

//@property (nonatomic) NSArray              *hpBar;
//@property (nonatomic) NSArray              *chargeBar;


@property (nonatomic) NSArray              *hpBar;
@property (nonatomic) NSArray              *chargeBar;

//UpIcon
//SIDESIcon
//DOWNIcon
@property (nonatomic) SKScene              *scene;
//ActionIcon

//update


-(id)initWithScene: (SKScene *)scene;

@end
