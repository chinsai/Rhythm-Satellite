//
//  Note.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Command.h"


@interface CommandNote : SKSpriteNode

@property (nonatomic, readonly) CommandType            command;
@property (nonatomic) BOOL                             isChangable;
@property (nonatomic) BOOL                             isActive;

-(CommandNote *)initWithDirection: (CommandType)direction;

-(void)changeTo: (CommandType) command;

-(void)changeToGoodTiming;
-(void)changeToGreatTiming;
-(void)changeToNeutral;
    
-(void) setIsActive:(BOOL)isActive;


@end
