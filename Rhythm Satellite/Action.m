//
//  Action.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/09.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Action.h"
#import "Command.h"

@implementation Action

-(Action *)init{
    
    if(!self){
        self = [super init];
    }
    
    _commands = [NSArray arrayWithObjects:[[Command alloc] initWithString:@"IDLE"],
                                            [[Command alloc] initWithString:@"IDLE"],
                                            [[Command alloc] initWithString:@"IDLE"],
                                            [[Command alloc] initWithString:@"IDLE"], nil];
    
    return self;
}

-(Action *)initWithAction:(ActionType) type{
    
    self = [self init];
    [self setActionWithType:type];
    
    return self;
}

-(Action *) initWithRandomAction{
    self = [self init];

    [self setActionWithType:(ActionType)arc4random_uniform(3)+1];
    
    return self;
}

-(void) randomAction{
    [self setActionWithType:(ActionType)arc4random_uniform(3)+1];
}

-(void) setActionWithType: (ActionType) type{
    switch (type) {
        case ATTACK:
            ((Command*)_commands[0]).input = UP;
            ((Command*)_commands[1]).input = UP;
            ((Command*)_commands[2]).input = SIDES;
            ((Command*)_commands[3]).input = UP;
            break;
            
        case BLOCK:
            ((Command*)_commands[0]).input = DOWN;
            ((Command*)_commands[1]).input = DOWN;
            ((Command*)_commands[2]).input = DOWN;
            ((Command*)_commands[3]).input = DOWN;
            break;
            
        case CHARGE:
            ((Command*)_commands[0]).input = DOWN;
            ((Command*)_commands[1]).input = DOWN;
            ((Command*)_commands[2]).input = UP;
            ((Command*)_commands[3]).input = UP;
            break;
            
        default:
            ((Command*)_commands[0]).input = NEUTRAL;
            ((Command*)_commands[1]).input = NEUTRAL;
            ((Command*)_commands[2]).input = NEUTRAL;
            ((Command*)_commands[3]).input = NEUTRAL;
            break;
    }

}

@end
