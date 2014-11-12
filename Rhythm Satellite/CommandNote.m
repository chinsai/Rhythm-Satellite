//
//  Note.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "CommandNote.h"

@interface CommandNote()


@end

@implementation CommandNote

-(CommandNote *)initWithDirection: (CommandType)direction{
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Note"];
        
    
    switch (direction) {
        case UP:
            self = [super initWithTexture:[atlas textureNamed:@"note_0001"]];
            break;
        case SIDES:
            self = [super initWithTexture:[atlas textureNamed:@"note_0002"]];
            break;
        case DOWN:
            self = [super initWithTexture:[atlas textureNamed:@"note_0003"]];
            break;
        default:
            self = [super initWithTexture:[atlas textureNamed:@"note_neutral"]];
            break;
    }

    
    _command = direction;
    _isChangable = YES;
    
    return self;
}


-(void)changeTo: (CommandType) command{
    
    _command = command;
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Note"];
    switch (command) {
        case UP:
            [self setTexture:[atlas textureNamed:@"note_0001"]];
            break;
        case SIDES:
            [self setTexture:[atlas textureNamed:@"note_0002"]];
            break;
        case DOWN:
            [self setTexture:[atlas textureNamed:@"note_0003"]];
            break;
        default:
            [self setTexture:[atlas textureNamed:@"note_neutral"]];
            break;
    }
}

@end
