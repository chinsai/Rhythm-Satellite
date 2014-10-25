//
//  GameControllerScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/24.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "GameControllerScene.h"
#import "BTPeripheralModule.h"
#import "MotionControllerModule.h"
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
@property (nonatomic, strong) MotionControllerModule        *controller;


@end


@implementation GameControllerScene

-(void)didMoveToView:(SKView *)view {
    
    if(!_btTransmitter){
        _btTransmitter = [[BTPeripheralModule alloc]init];
    }
    
    if(!_controller){
        _controller = [[MotionControllerModule alloc]init];
    }

    canRegister = YES;
    stopRegisterTime = 0;
    previousTime = 0;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_btTransmitter.isSubscribed) {
        [_btTransmitter toggleAdvertising];
        [_controller turnOn];
    }
    else{
        [_controller turnOff];
    }
}


-(void)update:(NSTimeInterval)currentTime {
    //update Accelerometer Values
    
    [_controller update:currentTime];
    
    if (_btTransmitter.isSubscribed && _controller.enabled) {

//        NSTimeInterval deltaTime = currentTime - previousTime;

        if( _controller.triggeredCommand.input != COMMAND_IDLE && _controller.canRegister){
            _btTransmitter.dataToSend = [[_controller.triggeredCommand inputInString] dataUsingEncoding:NSUTF8StringEncoding];
            [_btTransmitter sendData];
//            NSLog(@"data sent: %@", [_controller.triggeredCommand inputInString] );
        }

        previousTime = currentTime;
    }
    
    
    
}


-(void)willMoveFromView:(SKView *)view{
    [_controller turnOff];
    
}
@end
