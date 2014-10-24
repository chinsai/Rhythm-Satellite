//
//  Note.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Note.h"

@interface Note()


@end

@implementation Note

-(Note *)initWithDirection: (NoteType)direction atTime:(NSTimeInterval) time{
    
    self = [super initWithImageNamed:@"note"];
    
    switch (direction) {
        case RIGHT:
            self.zRotation = -M_PI_2;
            _direction = RIGHT;
            break;
            
        case DOWN:
            self.zRotation = -M_PI;
            _direction = DOWN;
            break;
            
        case LEFT:
            self.zRotation = M_PI_2;
            _direction = LEFT;
            break;
            
        default:
            _direction = UP;
            break;
    }
    _time = time;
    
    
    return self;
}

-(BOOL)matchInput: (Command*)command{
    
//    NSLog(@"input is %d, note is %d", command.input, _direction);
    if ((command.input == COMMAND_UP && _direction == UP) ||
        (command.input == COMMAND_DOWN && _direction == DOWN) ||
        (command.input == COMMAND_RIGHT && _direction == RIGHT) ||
        (command.input == COMMAND_LEFT && _direction == LEFT) ) {
//        NSLog(@"INPUT MATCHED");
        return YES;
    }
    return NO;
}


@end
