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
#import "iOSAppDelegate.h"


typedef enum mainSceneStateType{
    IDLE,
    SLEEPING,
    ALARM,
    WAITING,
    CONNECTED,
    GAMEOVER,
    MOTIONTEST
} iOSGameState;

@interface MainScene(){
    NSTimeInterval                  stopRegisterTime;    //time to avoid unwanted input
    NSTimeInterval                  previousTime;   //for recording the time of previous time
}

@property (nonatomic, strong) BTPeripheralModule            *btTransmitter;
@property (nonatomic, strong) MotionControllerModule        *controller;
@property (nonatomic, strong) AlarmClockModule              *alarm;
@property (nonatomic, strong) Character                     *character;
@property (nonatomic, strong) SKLabelNode                   *hitLabel;
@property (nonatomic) iOSGameState                          state;
@property (nonatomic, readonly) int                         numBeatsToWakeUp;
@property (nonatomic) int                                   numBeatsHit;


@end


@implementation MainScene

-(void)didMoveToView:(SKView *)view {
    
    if(!_btTransmitter){
        _btTransmitter = [[BTPeripheralModule alloc]init];
    }
    
    if(!_controller){
        _controller = [[MotionControllerModule alloc]init];
    }

    //HIT COUNT
    _hitLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _hitLabel.text = @"0";
    _hitLabel.fontSize = 70;
    _hitLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_hitLabel];

    
    stopRegisterTime = 0;
    previousTime = 0;
    _numBeatsToWakeUp = 60;
    _numBeatsHit = 0;
    _state = IDLE;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch (_state) {
        case IDLE:
            [_btTransmitter startAdvertising];
            _state = WAITING;
            break;
        case SLEEPING:
            _state = ALARM;
            [self playAlarm];
            [_controller turnOn];
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
            break;
        case SLEEPING:
            break;
        case ALARM:
            [self wakeUpCharacter:currentTime];
            _hitLabel.text = [NSString stringWithFormat:@"%d", _numBeatsHit];
            if( _numBeatsHit >= _numBeatsToWakeUp){
                [self stopAlarm];
                _state = WAITING;
                _numBeatsHit = 0;
                [_controller turnOff];
            }
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
                [_btTransmitter stopAdvertising];
                NSLog(@"jump to SLEEPING");
                break;
            }

            [self updateCommandAndSend:currentTime];
            break;
        case GAMEOVER:
            break;
        case MOTIONTEST:
            [self testMotion:currentTime];
            break;
        default:
            break;
    }
    
    previousTime = currentTime;
    
}

-(void)updateCommandAndSend:(NSTimeInterval) currentTime{
    
    //first get the latest command
    [_controller update:currentTime];
    
    if (_btTransmitter.isSubscribed && _controller.enabled) {
//         NSLog(@"Triggered command: %@", [_controller.triggeredCommand inputInString] );
        if( _controller.triggeredCommand.input != NEUTRAL){
            _btTransmitter.dataToSend = [[_controller.triggeredCommand inputInString] dataUsingEncoding:NSUTF8StringEncoding];
            [_btTransmitter sendData];
            // NSLog(@"Triggered command: %@", [_controller.triggeredCommand inputInString] );
        }
        
        
    }
}

-(void)testMotion:(NSTimeInterval) currentTime{
    
    if(!_controller.enabled){
        [_controller turnOn];
    }
    
    //first get the latest command
    [_controller update:currentTime];
    
    if( _controller.triggeredCommand.input != NEUTRAL){
         NSLog(@"Triggered command: %@", [_controller.triggeredCommand inputInString] );
    }
}

-(void)wakeUpCharacter:(NSTimeInterval) currentTime{

    //first get the latest command
    [_controller update:currentTime];
    
    if (_controller.enabled) {
                 NSLog(@"Triggered command: %@", [_controller.triggeredCommand inputInString] );
        if( _controller.triggeredCommand.input != NEUTRAL){

            _numBeatsHit++;
            
        }
    }

    
}

-(void)playAlarm{
    iOSAppDelegate *appDelegate = (iOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.bgmPlayer play];
}
-(void)stopAlarm{
    iOSAppDelegate *appDelegate = (iOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.bgmPlayer stop];
    appDelegate.bgmPlayer.currentTime = 0;
}

-(void)willMoveFromView:(SKView *)view{
    if (_controller.enabled) {
        [_controller turnOff];
    }
}
@end
