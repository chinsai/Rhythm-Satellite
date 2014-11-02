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

-(Command *)initWithString: (NSString *)commandString{
    if (!self) {
        self = [super init];
    }
    
    if ([commandString isEqualToString:@"UP"]) {
        _input = COMMAND_UP;
    }
    else if ([commandString isEqualToString:@"UP-LEFT"]) {
        _input = COMMAND_UP_LEFT;
    }
    else if ([commandString isEqualToString:@"UP-RIGHT"]) {
        _input = COMMAND_UP_RIGHT;
    }
    else if ([commandString isEqualToString:@"DOWN"]) {
        _input = COMMAND_DOWN;
    }
    else if ([commandString isEqualToString:@"LEFT"]) {
        _input = COMMAND_LEFT;
    }
    else if ([commandString isEqualToString:@"RIGHT"]) {
        _input = COMMAND_RIGHT;
    }
    else if ([commandString isEqualToString:@"SHAKE"]) {
        _input = COMMAND_SHAKE;
    }
    else if ([commandString isEqualToString:@"START"]) {
        _input = COMMAND_START;
    }
    else if ([commandString isEqualToString:@"TAP"]) {
        _input = COMMAND_TAP;
    }
    else{
        _input = COMMAND_IDLE;
    }

    return self;
}

-(void)setInputWithString:(NSString *)commandString{
    if ([commandString isEqualToString:@"UP"]) {
        _input = COMMAND_UP;
    }
    else if ([commandString isEqualToString:@"UP-LEFT"]) {
        _input = COMMAND_UP_LEFT;
    }
    else if ([commandString isEqualToString:@"UP-RIGHT"]) {
        _input = COMMAND_UP_RIGHT;
    }
    else if ([commandString isEqualToString:@"DOWN"]) {
        _input = COMMAND_DOWN;
    }
    else if ([commandString isEqualToString:@"LEFT"]) {
        _input = COMMAND_LEFT;
    }
    else if ([commandString isEqualToString:@"RIGHT"]) {
        _input = COMMAND_RIGHT;
    }
    else if ([commandString isEqualToString:@"SHAKE"]) {
        _input = COMMAND_SHAKE;
    }
    else if ([commandString isEqualToString:@"START"]) {
        _input = COMMAND_START;
    }
    else if ([commandString isEqualToString:@"TAP"]) {
        _input = COMMAND_TAP;
    }
    else{
        _input = COMMAND_IDLE;
    }

}

-(NSString *)inputInString{
    if(_input == COMMAND_UP){
        return @"UP";
    }
    else if(_input == COMMAND_UP_LEFT){
        return @"UP-LEFT";
    }
    else if(_input == COMMAND_UP_RIGHT){
        return @"UP-RIGHT";
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
    else if(_input == COMMAND_SHAKE){
        return @"SHAKE";
    }
    else if(_input == COMMAND_START){
        return @"START";
    }
    else if(_input == COMMAND_TAP){
        return @"TAP";
    }
    else{
        return @"IDLE";
    }
}
@end
