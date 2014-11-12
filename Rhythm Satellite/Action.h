//
//  Action.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/09.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


typedef enum actions{
    NONE,
    ATTACK,
    BLOCK,
    CHARGE,
    POWERATTACK,
    POWERBLOCK,
    POWERCHARGE
} ActionType;


@interface Action : NSObject

@property (nonatomic, strong) NSArray               *commands;

-(Action *) init;
-(Action *) initWithAction: (ActionType) action;
-(Action *) initWithRandomAction;
-(void) randomAction;
-(void) setActionWithType: (ActionType) action;
@end
