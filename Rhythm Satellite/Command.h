//
//  Command.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>


#define GREAT_TIMING_DELTA 0.1
#define GOOD_TIMING_DELTA 0.2


typedef enum commandTypes{
    COMMAND_SHAKE,
    COMMAND_UP,
    COMMAND_UP_LEFT,
    COMMAND_UP_RIGHT,
    COMMAND_RIGHT,
    COMMAND_DOWN,
    COMMAND_LEFT,
    COMMAND_TAP,
    COMMAND_SLIDE,
    COMMAND_START,
    COMMAND_IDLE
} InputCommand;


@interface Command : NSObject

@property (nonatomic) InputCommand             input;

-(NSString *)inputInString;
-(Command *)initWithString: (NSString *)commandString;
-(void)setInputWithString:(NSString *)commandString;

@end
