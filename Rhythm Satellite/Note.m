//
//  Note.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Note.h"

@interface Note()
@property (nonatomic, readonly) NoteType            direction;

@end

@implementation Note

-(Note *)initWithDirection: (NoteType)direction atTime:(NSTimeInterval) time{
    
    self = [super initWithImageNamed:@"note"];
    
    switch (direction) {
        case RIGHT:
            self.zRotation = -M_PI_2;
            direction = RIGHT;
            break;
            
        case DOWN:
            self.zRotation = -M_PI;
            direction = DOWN;
            break;
            
        case LEFT:
            self.zRotation = M_PI_2;
            direction = LEFT;
            break;
            
        default:
            direction = UP;
            break;
    }
    _time = time;
    
    
    return self;
}

@end
