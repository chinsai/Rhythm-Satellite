//
//  RSChargeIcon.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface RSChargeIcon : SKSpriteNode

@property (nonatomic) BOOL              charged;
@property (nonatomic) SKSpriteNode      *thunder;

-(void) charge;
-(void) discharge;

@end
