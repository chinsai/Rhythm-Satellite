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
    WAITING,
    CONNECTED,
    GAMEOVER,
} iOSGameState;

@interface MainScene(){
    NSTimeInterval                  stopRegisterTime;    //time to avoid unwanted input
    NSTimeInterval                  previousTime;   //for recording the time of previous time
}

@property (nonatomic, strong) BTPeripheralModule            *btTransmitter;
@property (nonatomic, strong) MotionControllerModule        *controller;
@property (nonatomic, strong) AlarmClockModule              *alarm;
@property (nonatomic, strong) Character                     *character;
@property (nonatomic) iOSGameState                          state;
@property (nonatomic) int                                   numBeatsToWakeUp;


@end


@implementation MainScene

-(void)didMoveToView:(SKView *)view {
    
    if(!_btTransmitter){
        _btTransmitter = [[BTPeripheralModule alloc]init];
    }
    
    if(!_controller){
        _controller = [[MotionControllerModule alloc]init];
    }

    stopRegisterTime = 0;
    previousTime = 0;
    _numBeatsToWakeUp = 60;
    _state = IDLE;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch (_state) {
        case IDLE:
            [_btTransmitter startAdvertising];
            _state = WAITING;
            break;
        case SLEEPING:
            break;
        case ALARM:
            break;
        case WAITING:
            [_btTransmitter toggleAdvertising];
            break;
        case CONNECTED:
            [_controller setInput:@"TAP"];
            break;
        case GAMEOVER:
            break;
        default:
            break;
    }
}


-(void)update:(NSTimeInterval)currentTime {
    
    
    switch (_state) {
        case IDLE:
            if(_btTransmitter.isSubscribed){
                [_controller turnOn];
                _state = CONNECTED;
                [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
                NSLog(@"jump to CONNECTED");
            }
            break;
        case SLEEPING:
            break;
        case ALARM:
            break;
        case WAITING:
            if(_btTransmitter.isSubscribed){
                [_controller turnOn];
                _state = CONNECTED;
                [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
                NSLog(@"jump to CONNECTED");
            }
            break;
        case CONNECTED:
            //if central doesnt subscribe to the controller
            if(!_btTransmitter.isSubscribed){
                [_controller turnOff];
                [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                _state = IDLE;
                NSLog(@"jump to IDLE");
            }
            else{
                [self updateCommandAndSend:currentTime];
            }
            break;
        case GAMEOVER:
            break;
        default:
            break;
    }
    
    previousTime = currentTime;
    
}

-(void)updateCommandAndSend:(NSTimeInterval) currentTime{
    
    [_controller update:currentTime];
    
    if (_btTransmitter.isSubscribed && _controller.enabled) {
//         NSLog(@"Triggered command: %@", [_controller.triggeredCommand inputInString] );
        if( _controller.triggeredCommand.input != COMMAND_IDLE){
            _btTransmitter.dataToSend = [[_controller.triggeredCommand inputInString] dataUsingEncoding:NSUTF8StringEncoding];
            [_btTransmitter sendData];
            // NSLog(@"Triggered command: %@", [_controller.triggeredCommand inputInString] );
        }
        
        
    }
}

-(void)willMoveFromView:(SKView *)view{
    [_controller turnOff];
}
@end
