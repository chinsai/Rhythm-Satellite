//
//  RSHPBar.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "RSHPBar.h"

@implementation RSHPBar

-(id)init{
    
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"HP"];
    SKTexture *frameTexture = [atlas textureNamed:@"HPFrame"];
    
    if(self = [super initWithTexture:frameTexture]){
        
        _bar = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"HPBar"]];
        //setting the anchor point so that the bar shrink from left to right
        
        _crop = [SKCropNode node];
        SKSpriteNode *mask = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(_bar.size.width, _bar.size.height)];
        mask.anchorPoint = CGPointMake(1.0, 0.5);
        mask.position = CGPointMake(mask.size.width/2, 0.0);
        [_crop setMaskNode:mask];
        [_crop addChild:_bar];
        [self addChild:_crop];
        
        _crop.zPosition = 10;
        

        
    }
    return self;
}

-(void)updateWithHPRatio:(CGFloat)ratio{
    SKAction* change = [SKAction scaleXTo:ratio duration:0.5];
    [_crop.maskNode runAction:change];
}
@end
