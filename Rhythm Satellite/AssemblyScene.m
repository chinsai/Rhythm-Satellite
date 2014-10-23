//
//  AssemblyScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AssemblyScene.h"
#import "Note.h"

NSTimeInterval timeElapsed;
NSTimeInterval previousTime;

@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// background
@property (nonatomic, strong) SKSpriteNode          *background;

// timeline
@property (nonatomic, strong) Timeline              *timeline;

// music




@end



@implementation AssemblyScene


-(void)didMoveToView:(SKView *)view {

    _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
    _timeline = [[Timeline alloc]initWithImageNamed:@"timeline" andHitSpotImageNamed:@"hitspot"];
    _timeline.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-_timeline.size.height/2-30);
    [self addChild:_timeline];
    
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: UP atTime: 1]];
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: RIGHT atTime: 2]];
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: DOWN atTime: 3]];
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: LEFT atTime: 4]];
    
    [_timeline initTimeline];
    
    timeElapsed = 0;
    previousTime = 0;
    
}


-(void)update:(NSTimeInterval)currentTime{
    if(previousTime == 0)
        previousTime = currentTime;
    timeElapsed += currentTime - previousTime;
    [_timeline update:timeElapsed];
    previousTime = currentTime;
}

@end
