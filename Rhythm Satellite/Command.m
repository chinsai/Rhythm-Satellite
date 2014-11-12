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
    _input = NEUTRAL;
    return self;
}

-(Command *)initWithString: (NSString *)commandString{
    if (!self) {
        self = [super init];
    }
    
    [self setInputWithString:commandString];

    return self;
}

-(void)setInputWithString:(NSString *)commandString{
    if ([commandString isEqualToString:@"UP"]) {
        _input = UP;
    }
    else if ([commandString isEqualToString:@"UP-LEFT"]) {
        _input = UP;
    }
    else if ([commandString isEqualToString:@"UP-RIGHT"]) {
        _input = UP;
    }
    else if ([commandString isEqualToString:@"DOWN"]) {
        _input = DOWN;
    }
    else if ([commandString isEqualToString:@"LEFT"]) {
        _input = SIDES;
    }
    else if ([commandString isEqualToString:@"RIGHT"]) {
        _input = SIDES;
    }
    else if ([commandString isEqualToString:@"SIDES"]) {
        _input = SIDES;
    }
    else if ([commandString isEqualToString:@"SHAKE"]) {
        _input = SHAKE;
    }
    else if ([commandString isEqualToString:@"START"]) {
        _input = START;
    }
    else if ([commandString isEqualToString:@"TAP"]) {
        _input = TAP;
    }
    else{
        _input = NEUTRAL;
    }


}

-(NSString *)inputInString{
    if(_input == UP){
        return @"UP";
    }
    else if(_input == DOWN){
        return @"DOWN";
    }
    else if(_input == SIDES){
        return @"SIDES";
    }
    else if(_input == SHAKE){
        return @"SHAKE";
    }
    else if(_input == START){
        return @"START";
    }
    else if(_input == TAP){
        return @"TAP";
    }
    else{
        return @"NEUTRAL";
    }
}
@end
