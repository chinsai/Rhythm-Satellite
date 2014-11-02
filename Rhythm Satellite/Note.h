//
//  Note.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Command.h"

typedef enum directions{
    NONE,
    UP,
    UP_LEFT,
    UP_RIGHT,
    RIGHT,
    DOWN,
    LEFT
} NoteType;


@interface Note : SKSpriteNode

@property (nonatomic) NSTimeInterval            time;
@property (nonatomic, readonly) NoteType            direction;


-(Note *)initWithDirection: (NoteType)direction atTime:(NSTimeInterval) time;
-(BOOL)matchInput: (Command*)command;

@end
