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
    
    if(!self){
        self = [super init];
    }
    
    
    switch (type) {
        case ATTACK:
            _commands = [NSArray arrayWithObjects:
                         [[Command alloc] initWithString:@"UP"],
                         [[Command alloc] initWithString:@"UP"],
                         [[Command alloc] initWithString:@"RIGHT"],
                         [[Command alloc] initWithString:@"UP"], nil];
            break;
            
        case BLOCK:
            _commands = [NSArray arrayWithObjects:
                         [[Command alloc] initWithString:@"RIGHT"],
                         [[Command alloc] initWithString:@"DOWN"],
                         [[Command alloc] initWithString:@"RIGHT"],
                         [[Command alloc] initWithString:@"DOWN"], nil];
            break;
            
        case CHARGE:
            _commands = [NSArray arrayWithObjects:
                         [[Command alloc] initWithString:@"DOWN"],
                         [[Command alloc] initWithString:@"DOWN"],
                         [[Command alloc] initWithString:@"DOWN"],
                         [[Command alloc] initWithString:@"DOWN"], nil];
            break;
            
        default:
            _commands = [NSArray arrayWithObjects:
                         [[Command alloc] initWithString:@"IDLE"],
                         [[Command alloc] initWithString:@"IDLE"],
                         [[Command alloc] initWithString:@"IDLE"],
                         [[Command alloc] initWithString:@"IDLE"], nil];
            break;
    }
    
    
    return self;
}


@end
