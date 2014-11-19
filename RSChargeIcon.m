//
//  RSChargeIcon.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "RSChargeIcon.h"

@implementation RSChargeIcon

-(id)init{
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Charge"];
    SKTexture *baseTexture = [atlas textureNamed:@"chargeball"];
    SKTexture *thunderTexture = [atlas textureNamed:@"chargethunder"];
    
    if(self=[super initWithTexture:baseTexture]){
        _thunder = [SKSpriteNode spriteNodeWithTexture:thunderTexture];
        _charged = NO;
        
        [self addChild:_thunder];
        _thunder.alpha = 0.0;
    }
    return self;
}

-(void)charge{
    _charged = YES;
    [_thunder runAction:[self popAction]];
    
    
}

-(SKAction *) popAction{
    SKAction *big = [SKAction scaleTo:1.1 duration:0.1];
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.1];
    SKAction *in = [SKAction group:@[big, fadeIn ]];
    SKAction *small = [SKAction scaleTo:1 duration:0.1];
    SKAction *action = [SKAction sequence:@[in, small]];
    return action;
}

-(void)discharge{
    _charged = NO;
    [_thunder runAction:[SKAction fadeOutWithDuration:0.1]];
}
@end
