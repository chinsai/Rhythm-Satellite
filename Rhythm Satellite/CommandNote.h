//
//  Note.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Command.h"

//typedef enum directions{
//    NONE,
//    UP,
//    UP_LEFT,
//    UP_RIGHT,
//    RIGHT,
//    DOWN,
//    LEFT
//} NoteType;




@interface CommandNote : SKSpriteNode

@property (nonatomic, readonly) CommandType            command;
@property (nonatomic) BOOL                              isChangable;

-(CommandNote *)initWithDirection: (CommandType)direction;

-(void)changeTo: (CommandType) command;
//changing texture functions

@end
