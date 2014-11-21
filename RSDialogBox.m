//
//  RSDialogBox.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/21.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "RSDialogBox.h"

@interface RSDialogBox()

@property (nonatomic) SKLabelNode           *titleLabel;
@property (nonatomic) SKSpriteNode           *up;
@property (nonatomic) SKSpriteNode           *down;
@property (nonatomic) SKLabelNode           *upLabel;
@property (nonatomic) SKLabelNode           *downLabel;

@end

@implementation RSDialogBox

+(id)initConfirmDialogBoxWithTitle: (NSString *)title{
    RSDialogBox *box;
    
    if ((box=[super spriteNodeWithImageNamed:@"dialogBox"])) {
        box.titleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
        box.titleLabel.fontColor = [SKColor whiteColor];
        box.titleLabel.fontSize = 36;
        box.titleLabel.text = title;
        box.titleLabel.position = CGPointMake(0.0, 110.0);
        [box addChild:box.titleLabel];
        
        box.up = [RSDialogBox initiateYesIcon];
        [box addChild:box.up];
        
        box.upLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
        box.upLabel.text = @"YES";
        box.upLabel.fontColor = [SKColor whiteColor];
        box.upLabel.fontSize = 24;
        box.upLabel.position = CGPointMake(-80.0, -115.0);
        box.up.position = CGPointMake(-80.0, -15.0);
        [box addChild:box.upLabel];
    }
    return box;
}
+(id)initBooleanDialogBoxWithTitle: (NSString *)title{
    RSDialogBox *box;
    
    if ((box=[super spriteNodeWithImageNamed:@"dialogBox"])) {
        box.titleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
        box.titleLabel.fontColor = [SKColor whiteColor];
        box.titleLabel.fontSize = 36;
        box.titleLabel.text = title;
        box.titleLabel.position = CGPointMake(0.0, 110.0);
        [box addChild:box.titleLabel];
        
        box.up = [RSDialogBox initiateYesIcon];
        [box addChild:box.up];
        box.up.zPosition=2.0;
        box.down = [RSDialogBox initiateNoIcon];
        [box addChild:box.down];
        box.down.zPosition=2.0;
        
        
        box.upLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
        box.upLabel.text = @"YES";
        box.upLabel.fontColor = [SKColor whiteColor];
        box.upLabel.fontSize = 24;
        box.upLabel.position = CGPointMake(-80.0, -115.0);
        box.up.position = CGPointMake(-80.0, -15.0);
        [box addChild:box.upLabel];
        
        box.downLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
        box.downLabel.text = @"NO";
        box.downLabel.fontColor = [SKColor whiteColor];
        box.downLabel.fontSize = 24;
        box.downLabel.position = CGPointMake(80.0, -115.0);
        box.down.position = CGPointMake(80.0, -15.0);
        [box addChild:box.downLabel];
    }
    
    return box;
}

+(id)initiateYesIcon{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Nori_Up"];
    SKTexture *firstFrame = [atlas textureNamed:@"nori_up_0001"];
    SKTexture *secondFrame = [atlas textureNamed:@"nori_up_0003"];
    NSArray *frames = [NSArray arrayWithObjects:firstFrame,secondFrame, nil];
    SKSpriteNode *up = [SKSpriteNode spriteNodeWithTexture:firstFrame];
    [up setScale:0.4];
    [up runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:frames timePerFrame:1.0]]];
    return up;
}

+(id)initiateNoIcon{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Nori_Down"];
    SKTexture *firstFrame = [atlas textureNamed:@"nori_down_0001"];
    SKTexture *secondFrame = [atlas textureNamed:@"nori_down_0003"];
    NSArray *frames = [NSArray arrayWithObjects:firstFrame,secondFrame, nil];
    SKSpriteNode *down = [SKSpriteNode spriteNodeWithTexture:firstFrame];
    [down setScale:0.4];
    [down runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:frames timePerFrame:1.0]]];
    return down;
}

-(void)dealloc{
    [self.parent removeFromParent];
}
@end
