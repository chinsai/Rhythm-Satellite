//
//  RSDialogBox.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/21.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface RSDialogBox : SKSpriteNode

+(id)initConfirmDialogBoxWithTitle: (NSString *)title;
+(id)initBooleanDialogBoxWithTitle: (NSString *)title;

@end
