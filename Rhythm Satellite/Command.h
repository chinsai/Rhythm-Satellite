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


typedef enum directions{
    NEUTRAL,
    UP,
    SIDES,
    DOWN,
    SHAKE,
    START,
    TAP
} CommandType;


@interface Command : NSObject

@property (nonatomic) CommandType             input;

-(NSString *)inputInString;
-(Command *)initWithString: (NSString *)commandString;
-(void)setInputWithString:(NSString *)commandString;

@end
