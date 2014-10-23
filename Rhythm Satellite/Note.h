//
//  Note.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum directions{
    UP,
    RIGHT,
    DOWN,
    LEFT
} NoteType;


@interface Note : SKSpriteNode

@property (nonatomic) NSTimeInterval            time;

-(Note *)initWithDirection: (NoteType)direction atTime:(NSTimeInterval) time;

@end
