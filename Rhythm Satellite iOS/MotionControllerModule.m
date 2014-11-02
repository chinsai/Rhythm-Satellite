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
    NSLog(@"motion controller On");
}

-(void)turnOff{
    if ([_mManager isDeviceMotionActive] == YES) {
        [_mManager stopDeviceMotionUpdates];
        NSLog(@"motion controller Off");
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
            [self setInput:@"IDLE"];
        }
    }
    else{
//        NSLog(@"Gravity X: %f", gravityX);
//        NSLog(@"Gravity Y: %f", gravityY);
//        NSLog(@"Gravity Z: %f", gravityZ);
        if ( deltaX > DELTA_THRESHOLD){
            
            if (gravityY < -GRAVITY_THRESHOLD && gravityZ < GRAVITY_THRESHOLD/4 && gravityZ > -GRAVITY_THRESHOLD/4) {
                [self setInput:@"UP"];
            }
            else if (gravityY < -GRAVITY_THRESHOLD/2 && gravityZ > GRAVITY_THRESHOLD/4 && gravityZ < GRAVITY_THRESHOLD) {
                [self setInput:@"UP-LEFT"];
            }
            else if (gravityY < -GRAVITY_THRESHOLD/2 && gravityZ < -GRAVITY_THRESHOLD/4 && gravityZ > -GRAVITY_THRESHOLD ) {
                [self setInput:@"UP-RIGHT"];
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
                [self setInput:@"SHAKE"];
            }
            
            //avoid unintended iinput
            _canRegister = NO;
        }
        else if (self.triggeredCommand.input == COMMAND_TAP){
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
