//
//  Command.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum commandTypes{
    COMMAND_ANY,
    COMMAND_UP,
    COMMAND_RIGHT,
    COMMAND_DOWN,
    COMMAND_LEFT
} MotionCommand;


@interface Command : NSObject

@end