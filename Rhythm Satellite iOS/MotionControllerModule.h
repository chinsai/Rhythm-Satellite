//
//  MotionControllerModule.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/25.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Command.h"

@interface MotionControllerModule : NSObject

@property (nonatomic, strong) Command *             triggeredCommand;
@property (nonatomic) BOOL                          canRegister;

@property (nonatomic) BOOL                          enabled;

-(void)update:(NSTimeInterval)currentTime;
-(void)turnOn;
-(void)turnOff;

@end