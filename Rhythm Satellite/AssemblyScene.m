//
//  AssemblyScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AssemblyScene.h"

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
//    NSLog(@"x: %f, y: %f", CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//    _background.position = CGPointMake(640, 360);
    [self addChild:_background];
    
    
    
    
    
}


-(void)update:(NSTimeInterval)currentTime{
    
}

@end
