//
//  Command.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Command.h"

@implementation Command

-(Command *)initWithString: (NSString *)direction{
    if (!self) {
        self = [super init];
    }
    
    if ([direction isEqualToString:@"UP"]) {
        _input = COMMAND_UP;
    }
    else if ([direction isEqualToString:@"DOWN"]) {
        _input = COMMAND_DOWN;
    }
    else if ([direction isEqualToString:@"LEFT"]) {
        _input = COMMAND_LEFT;
    }
    else if ([direction isEqualToString:@"RIGHT"]) {
        _input = COMMAND_RIGHT;
    }
    else{
        _input = COMMAND_ANY;
    }

    return self;
}

@end
