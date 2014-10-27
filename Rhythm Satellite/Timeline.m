//
//  Timeline.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Timeline.h"

#define GREAT_DELTA 20
#define GOOD_DELTA 40
#define BAD_DELTA 50
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
    
    velocity = (self.size.width/2 - _hitSpot.position.x) / 2;
    
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
    if (_notes.count == 0) {
        return;
    }
    for (Note * note in _notes) {
        note.position = CGPointMake(startingX + (note.time-timeElapsed)*velocity, 0);
//        NSLog(@"x: %f, y:%f", note.position.x, note.position.y);
    }
    Note * note = _notes[0];
    if( note.position.x < -self.size.width/2 - note.size.width/2){
        [note removeFromParent];
        [_notes removeObject:note];
    }
}


-(TimingType) checkInput:(Command *)command{
    
    if (_notes.count == 0) {
        return NO_GRADE;
    }
    
    //check input timing for the closest note only
    int i = 0;
    Note* note = _notes[i];
    while (note.position.x < _hitSpot.position.x - BAD_DELTA/2) {
        note = _notes[++i];
    }
    float delta = fabsf(note.position.x - _hitSpot.position.x);
    if (delta <= GREAT_DELTA){
        if( [note matchInput:command]){
            [note removeFromParent];
            [_notes removeObject:note];
            return GREAT;
        }
        else{
            return BAD;
        }
    }
    else if(delta <= GOOD_DELTA){
        if( [note matchInput:command]){
            [note removeFromParent];
            [_notes removeObject:note];
            return GOOD;
        }
        else{
            return BAD; 
        }
    }
    else if(delta > GOOD_DELTA && delta < BAD_DELTA ){
        [note removeFromParent];
        [_notes removeObject:note];
        return BAD;
    }
    return NO_GRADE;
}

@end
