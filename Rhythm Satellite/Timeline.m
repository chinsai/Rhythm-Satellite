//
//  Timeline.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Timeline.h"


@interface Timeline()


@property (nonatomic, strong) SKSpriteNode          *hitSpot;


@end

float startingX;
float velocity;


@implementation Timeline

-(Timeline *) initWithImageNamed: (NSString *)image andHitSpotImageNamed:(NSString *)spotImage {
    
    _notes = [[NSMutableArray alloc] init];
    
    self = [super initWithImageNamed:image];
    
    //initializing the position of the hit spot, and place it on the left hand side
    _hitSpot = [SKSpriteNode spriteNodeWithImageNamed:spotImage];
    _hitSpot.position = CGPointMake(-self.size.width/2+_hitSpot.size.width, 0);
    
    [self addChild:_hitSpot];
    
    velocity = (self.size.width/2 - _hitSpot.position.x) / 4;
    
    return self;

}

-(void)initTimeline{
    if(!_notes){
        return;
    }
    for (Note * note in _notes) {
        startingX = self.size.width/2 + note.size.width/2;
        note.position = CGPointMake(startingX + note.time*velocity, 0);
        [self addChild:note];
//        NSLog(@"x: %f, y:%f", note.position.x, note.position.y);
    }
}


-(void)update:(NSTimeInterval)timeElapsed{
    if(!_notes){
        return;
    }
    for (Note * note in _notes) {
        note.position = CGPointMake(startingX + (note.time-timeElapsed)*velocity, 0);
//        NSLog(@"x: %f, y:%f", note.position.x, note.position.y);
    }
    if(!_notes){
        Note * note = _notes[0];
        if( note.position.x < -self.size.width/2 - note.size.width/2){
            [note removeFromParent];
            [_notes removeObject:note];
        }

    }
}

@end
