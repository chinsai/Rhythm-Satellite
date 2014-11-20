//
//  RSHPBar.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface RSHPBar : SKSpriteNode

@property (nonatomic) SKCropNode            *crop;
@property (nonatomic) SKSpriteNode          *bar;

-(void)updateWithHPRatio:(CGFloat)ratio;
@end
