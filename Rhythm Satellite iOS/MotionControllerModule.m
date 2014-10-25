//
//  MotionControllerModule.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/25.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "MotionControllerModule.h"
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"

#define DELTA_THRESHOLD 1
#define REGISTER_INTERVAL 0.1
#define GRAVITY_THRESHOLD 0.8

@interface MotionControllerModule(){
    NSTimeInterval                  stopRegisterTime;   //time to avoid unwanted input
    NSTimeInterval                  previousTime;       //for recording the time of previous time
    double                          prevAccelerationX;
}

@property (nonatomic, strong) CMMotionManager               *mManager;                  //CoreMotion Manager

@end

@implementation MotionControllerModule

-(MotionControllerModule *)init{
    
    
    if(!self){
        self = [super init];
    }
    
    //Set up motion sensor update interval
    NSTimeInterval updateInterval = 0.01;
    _mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    if ([_mManager isDeviceMotionAvailable] == YES) {
        [_mManager setDeviceMotionUpdateInterval:updateInterval];
    }
    
    prevAccelerationX = 0;
    _canRegister = YES;
    stopRegisterTime = 0;
    previousTime = 0;
    
    return self;
}

-(BOOL)enabled{
    return [_mManager isDeviceMotionActive];
}

-(void)turnOn{
    [_mManager startDeviceMotionUpdates];
}

-(void)turnOff{
    if ([_mManager isDeviceMotionActive] == YES) {
        [_mManager stopDeviceMotionUpdates];
    }
}


-(void)setInput: (NSString *)input{
    if (!_triggeredCommand) {
        _triggeredCommand = [[Command alloc]init];
    }
    [_triggeredCommand setInputWithString:input];
}


-(void)update:(NSTimeInterval)currentTime {

    
    NSTimeInterval deltaTime = currentTime - previousTime;
    
    double newAccelerationX = _mManager.deviceMotion.userAcceleration.x;
    double deltaX = newAccelerationX - prevAccelerationX;
    
    double gravityX = _mManager.deviceMotion.gravity.x;
    double gravityY = _mManager.deviceMotion.gravity.y;
    double gravityZ = _mManager.deviceMotion.gravity.z;
    
    if(!_canRegister){
        
        if (stopRegisterTime > REGISTER_INTERVAL){
            stopRegisterTime = 0;
            _canRegister = YES;
        }
        else{
            stopRegisterTime += deltaTime;
        }
    }
    else{
        
        if ( deltaX > DELTA_THRESHOLD){
            
            //stop registering unwanted commandes
            if (gravityY < -GRAVITY_THRESHOLD) {
                [self setInput:@"UP"];
            }
            else if (gravityX < -GRAVITY_THRESHOLD){
                [self setInput:@"DOWN"];
            }
            else if (gravityZ > GRAVITY_THRESHOLD){
                [self setInput:@"RIGHT"];
            }
            else if (gravityZ < -GRAVITY_THRESHOLD){
                [self setInput:@"LEFT"];
            }else{
                [self setInput:@"ANY"];
            }
            
            //avoid unintended iinput
            _canRegister = NO;
        }
        else{
            [self setInput:@"IDLE"];
        }
        
    }
    
    prevAccelerationX = newAccelerationX;
    previousTime = currentTime;


}
@end
