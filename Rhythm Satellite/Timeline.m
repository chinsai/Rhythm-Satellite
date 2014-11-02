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

float startingY;
float velocity;


@implementation Timeline

-(Timeline *) initWithImageNamed: (NSString *)image andHitSpotImageNamed:(NSString *)spotImage {
    
    _notes = [[NSMutableArray alloc] init];
    
    self = [super initWithImageNamed:image];
    
    //initializing the position of the hit spot, and place it on the left hand side
    _hitSpot = [SKSpriteNode spriteNodeWithImageNamed:spotImage];
    _hitSpot.position = CGPointMake( 0 , -self.size.height/2);
    
    [self addChild:_hitSpot];
    
    velocity = (self.size.height/2 - _hitSpot.position.y) / 2;
    
    return self;

}

-(void)initTimeline{
    if(!_notes){
        return;
    }
    for (Note * note in _notes) {
        startingY = self.size.height/2 + note.size.height/2;
        note.position = CGPointMake(0, startingY + note.time*velocity);
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
        note.position = CGPointMake(0, startingY + (note.time-timeElapsed)*velocity);
//        NSLog(@"x: %f, y:%f", note.position.x, note.position.y);
    }
    Note * note = _notes[0];
    if( note.position.y < -self.size.height/2 - note.size.height/2){
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
    while (note.position.y < _hitSpot.position.y - BAD_DELTA/2) {
        note = _notes[++i];
    }
    NSLog(@"command: %d", note.direction);
    float delta = fabsf(note.position.y - _hitSpot.position.y);
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
