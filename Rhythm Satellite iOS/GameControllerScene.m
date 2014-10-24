//
//  GameControllerScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/24.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "GameControllerScene.h"
#import "BTPeripheralModule.h"
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"

#define DELTA_THRESHOLD 1
#define REGISTER_INTERVAL 0.1
#define GRAVITY_THRESHOLD 0.8
#define INPUT_TOLERANCE 0.1

@interface GameControllerScene(){
    BOOL                            canRegister;
    NSTimeInterval                  stopRegisterTime;    //time to avoid unwanted input
    NSTimeInterval                  previousTime;   //for recording the time of previous time
}

@property (nonatomic, strong) BTPeripheralModule            *btTransmitter;
@property (nonatomic, strong) CMMotionManager               *mManager;                  //CoreMotion Manager
@property (nonatomic) double                                preAccelerationX;                  //previous Acceleration.X Value


@end


@implementation GameControllerScene

-(void)didMoveToView:(SKView *)view {
    
    if(!_btTransmitter){
        _btTransmitter = [[BTPeripheralModule alloc]init];
    }
    
    //Set up motion sensor update interval
    NSTimeInterval updateInterval = 0.01;
    _mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    if ([_mManager isDeviceMotionAvailable] == YES) {
        [_mManager setDeviceMotionUpdateInterval:updateInterval];
    }
    
    _preAccelerationX = 0;
    canRegister = YES;
    stopRegisterTime = 0;
    previousTime = 0;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_btTransmitter.isSubscribed) {
        [_btTransmitter toggleAdvertising];
        [_mManager startDeviceMotionUpdates];
    }
    else{
        
    }
}


-(void)update:(NSTimeInterval)currentTime {
    //update Accelerometer Values
    if (_btTransmitter.isSubscribed) {
        
        NSTimeInterval deltaTime = currentTime - previousTime;
        
        double newAccelerationX = _mManager.deviceMotion.userAcceleration.x;
        double deltaX = newAccelerationX - _preAccelerationX;
        
        double gravityX = _mManager.deviceMotion.gravity.x;
        double gravityY = _mManager.deviceMotion.gravity.y;
        double gravityZ = _mManager.deviceMotion.gravity.z;
        
        if(!canRegister){
            if (stopRegisterTime > REGISTER_INTERVAL){
                stopRegisterTime = 0;
                canRegister = YES;
            }
            else{
                stopRegisterTime += deltaTime;
            }
        }
        else{

            if ( deltaX > DELTA_THRESHOLD){
                
                //stop registering unwanted commandes
                if (gravityY < -GRAVITY_THRESHOLD) {
                    _btTransmitter.dataToSend = [@"UP" dataUsingEncoding:NSUTF8StringEncoding];
                }
                else if (gravityX < -GRAVITY_THRESHOLD){
                    _btTransmitter.dataToSend = [@"DOWN" dataUsingEncoding:NSUTF8StringEncoding];
                }
                else if (gravityZ > GRAVITY_THRESHOLD){
                    _btTransmitter.dataToSend = [@"RIGHT" dataUsingEncoding:NSUTF8StringEncoding];
                }
                else if (gravityZ < -GRAVITY_THRESHOLD){
                    _btTransmitter.dataToSend = [@"LEFT" dataUsingEncoding:NSUTF8StringEncoding];
                }else{
                    _btTransmitter.dataToSend = [@"UNKNOWN" dataUsingEncoding:NSUTF8StringEncoding];
                }
                
                //avoid unintended iinput
                canRegister = NO;
                
                [_btTransmitter sendData];
//                NSLog(@"data sent");
            }
        
        }
        
        _preAccelerationX = newAccelerationX;
        previousTime = currentTime;
    }
    
    
    
}


-(void)willMoveFromView:(SKView *)view{
    if ([_mManager isAccelerometerActive] == YES) {
        [_mManager stopDeviceMotionUpdates];
    }
    
}
@end
