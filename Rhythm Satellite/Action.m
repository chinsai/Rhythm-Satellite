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
    _actionType = NONE;
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
            _actionType = type;
            break;
            
        case BLOCK:
            ((Command*)_commands[0]).input = DOWN;
            ((Command*)_commands[1]).input = DOWN;
            ((Command*)_commands[2]).input = DOWN;
            ((Command*)_commands[3]).input = DOWN;
            _actionType = type;
            break;
            
        case CHARGE:
            ((Command*)_commands[0]).input = UP;
            ((Command*)_commands[1]).input = UP;
            ((Command*)_commands[2]).input = DOWN;
            ((Command*)_commands[3]).input = DOWN;
            _actionType = type;
            break;
            
        default:
            ((Command*)_commands[0]).input = NEUTRAL;
            ((Command*)_commands[1]).input = NEUTRAL;
            ((Command*)_commands[2]).input = NEUTRAL;
            ((Command*)_commands[3]).input = NEUTRAL;
            _actionType = NONE;
            break;
    }

}

-(NSString *) toString{
    switch (_actionType) {
        case ATTACK:
            return @"ATTACK";
        case BLOCK:
            return @"BLOCK";
        case CHARGE:
            return @"CHARGE";
        default:
            return @"NONE";
    }
}

+(Action *) retrieveActionFrom: (NSArray *)commands{
    
    ActionType act = NONE;
    
    if ( ((Command*)commands[0]).input == UP &&
         ((Command*)commands[1]).input == UP &&
         ((Command*)commands[2]).input == SIDES &&
         ((Command*)commands[3]).input == UP) {
        act = ATTACK;
    }
    else if ( ((Command*)commands[0]).input == DOWN &&
        ((Command*)commands[1]).input == DOWN &&
        ((Command*)commands[2]).input == DOWN &&
        ((Command*)commands[3]).input == DOWN) {
        act = BLOCK;
    }
    else if ( ((Command*)commands[0]).input == UP &&
             ((Command*)commands[1]).input == UP &&
             ((Command*)commands[2]).input == DOWN &&
             ((Command*)commands[3]).input == DOWN) {
        act = CHARGE;
    }
    else{
        return nil;
    }
    
    return [[Action alloc] initWithAction:act];
}

@end
