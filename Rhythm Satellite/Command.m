//
//  Command.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Command.h"

@implementation Command

-(Command *)init{
    if (!self) {
        self = [super init];
    }
    _input = COMMAND_IDLE;
    return self;
}

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
    else if ([direction isEqualToString:@"ANY"]) {
        _input = COMMAND_ANY;
    }
    else{
        _input = COMMAND_IDLE;
    }

    return self;
}

-(void)setInputWithString:(NSString *)direction{
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
    else if ([direction isEqualToString:@"ANY"]) {
        _input = COMMAND_ANY;
    }
    else{
        _input = COMMAND_IDLE;
    }

}

-(NSString *)inputInString{
    if(_input == COMMAND_UP){
        return @"UP";
    }
    else if(_input == COMMAND_DOWN){
        return @"DOWN";
    }
    else if(_input == COMMAND_LEFT){
        return @"LEFT";
    }
    else if(_input == COMMAND_RIGHT){
        return @"RIGHT";
    }
    else if(_input == COMMAND_ANY){
        return @"ANY";
    }
    else{
        return @"IDLE";
    }
}
@end
