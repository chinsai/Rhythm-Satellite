//
//  GameControllerScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/24.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "MainScene.h"
#import "BTPeripheralModule.h"
#import "MotionControllerModule.h"
#import "AlarmClockModule.h"
#import "Character.h"
#import "AppDelegate.h"


typedef enum mainSceneStateType{
    IDLE,
    SLEEPING,
    ALARM,
    ADVERTISING,
    CONNECTED,
    GAMEOVER,
} iOSGameState;

@interface MainScene(){
    BOOL                            canRegister;
    NSTimeInterval                  stopRegisterTime;    //time to avoid unwanted input
    NSTimeInterval                  previousTime;   //for recording the time of previous time
}

@property (nonatomic, strong) BTPeripheralModule            *btTransmitter;
@property (nonatomic, strong) MotionControllerModule        *controller;
@property (nonatomic, strong) AlarmClockModule              *alarm;
@property (nonatomic, strong) Character                     *character;
@property (nonatomic) iOSGameState                          *state;


@end


@implementation MainScene

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
