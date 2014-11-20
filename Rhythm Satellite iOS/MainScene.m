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
#import "Player.h"
#import "iOSAppDelegate.h"

#define GOOD_TIMING_DELTA 0.2

typedef enum mainSceneStateType{
    IDLE,
    SLEEPING,
    ALARM,
    WAITING,
    CONNECTED,
    PLAYING,
    GAMEOVER,
    MOTIONTEST
} iOSGameState;

CGFloat             lastY;
NSTimeInterval      lastTimeStamp;
SKNode              *nodeInTouch;
CGPoint             originalPosition;
CGFloat             velocityY;
@interface MainScene()

@property (nonatomic, strong) BTPeripheralModule            *btTransmitter;
@property (nonatomic, strong) MotionControllerModule        *controller;
@property (nonatomic, strong) AlarmClockModule              *alarm;
@property (nonatomic, strong) Character                     *character;
@property (nonatomic) iOSGameState                          state;
@property (nonatomic, readonly) int                         numBeatsToWakeUp;
@property (nonatomic) int                                   numBeatsHit;
@property (nonatomic) Player                                *defaultPlayer;
@property (nonatomic) SKLabelNode                           *currentTimeLabel;
@property (nonatomic) SKLabelNode                           *statusLabel;
@property (nonatomic) SKSpriteNode                          *alarmbutton;
@property (nonatomic) float                                 secPerBeat;
@property (nonatomic) BOOL                                  isInputTiming;


@end

#define CHARACTER_NODE_NAME @"nori"
#define ALARM_BUTTON_NODE_NAME @"alarmbuttonnori"
#define MAX_CLOCK_Y 600


@implementation MainScene

-(void)didMoveToView:(SKView *)view {
    
    if(!_btTransmitter){
        _btTransmitter = [[BTPeripheralModule alloc]init];
    }
    
    if(!_controller){
        _controller = [[MotionControllerModule alloc]init];
    }
    
    originalPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100.0);
    
    //mainplayer
    if (!_defaultPlayer) {
        _defaultPlayer = [[Player alloc]initWithPlayerName:@"Kiron"];
        _defaultPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:30 withDef:15 withMoney:1000];
        _defaultPlayer.character.position = originalPosition;
        [_defaultPlayer.character fireAnimationForState:NoriAnimationStateIdle];
        [_defaultPlayer.character setScale:0.8];
        _defaultPlayer.character.name=CHARACTER_NODE_NAME;
        _defaultPlayer.character.userInteractionEnabled = NO;
        [self addChild:_defaultPlayer.character];
        
    }

    _alarm = [[AlarmClockModule alloc]init];

    //Current Time Label
    _currentTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
    _currentTimeLabel.text = [AlarmClockModule getCurrentTimeInString];
    _currentTimeLabel.fontSize = 120;
    _currentTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame), 500.0);
    _currentTimeLabel.zPosition = 10;
    [self addChild:_currentTimeLabel];
    
    //Status Label
    _statusLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
    _statusLabel.text = @"TAP To Get Ready";
    _statusLabel.fontSize = 30;
    _statusLabel.position = CGPointMake(CGRectGetMidX(self.frame), 35.0);
    [self addChild:_statusLabel];
    
    
     _alarmbutton = [SKSpriteNode spriteNodeWithImageNamed:@"musicnote"];
    _alarmbutton.position = CGPointMake(CGRectGetMidX(self.frame)+120.0, 450.0);
    _alarmbutton.color = [SKColor grayColor];
    _alarmbutton.colorBlendFactor = 1.0;
    _alarmbutton.alpha = 0.5;
    _alarmbutton.name=ALARM_BUTTON_NODE_NAME;
    [self addChild:_alarmbutton];
    
     
     
    _secPerBeat = 60.0/120.0;
    _numBeatsToWakeUp = 16;
    _numBeatsHit = 0;
    _isInputTiming = NO;
    [self updateState:IDLE];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    switch (_state) {
        
        case CONNECTED:
            if ([node.name isEqualToString:CHARACTER_NODE_NAME]) {
                lastY = location.y;
                lastTimeStamp = event.timestamp;
                nodeInTouch = node;
            }
            break;
        default:
            break;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    switch (_state) {
        case CONNECTED:
            if (nodeInTouch) {
                CGFloat distance = location.y - lastY;
                
                //avoid dropping lower than the original position
                if (nodeInTouch.position.y < originalPosition.y) {
                    nodeInTouch.position = CGPointMake(nodeInTouch.position.x, originalPosition.y);
                    distance = 0.0;
                }
                else{
                    nodeInTouch.position = CGPointMake(nodeInTouch.position.x, nodeInTouch.position.y + distance);
                }
                
                CGFloat alpha = (MAX_CLOCK_Y - _defaultPlayer.character.position.y)/(MAX_CLOCK_Y - originalPosition.y);
                [_currentTimeLabel setAlpha:alpha];
                _currentTimeLabel.position = CGPointMake(_currentTimeLabel.position.x, _currentTimeLabel.position.y + distance/20.0);
                
                velocityY = distance / (event.timestamp - lastTimeStamp);
//                NSLog(@"velocity: %f", velocityY);
                
                //update last position and timing
                lastY = location.y;
                lastTimeStamp = event.timestamp;
            }
            
            break;
        default:
            break;
            
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    
    switch (_state) {
        case IDLE:
            //alarm button is pressed
            //character will go to sleep
            if ([node.name isEqualToString:ALARM_BUTTON_NODE_NAME]) {
                [self updateState:SLEEPING];
                [_defaultPlayer.character fireAnimationForState:NoriAnimationStateSleeping];
                _alarmbutton.color = [SKColor whiteColor];
                _alarmbutton.alpha = 1.0;
            }
            //the character is pressed
            if ([node.name isEqualToString:CHARACTER_NODE_NAME]) {
                [_btTransmitter startAdvertising];
                [self updateState:WAITING];
            }
            
            
            break;
        case SLEEPING:
            //Button is pressed
            //in sleeping mode, when its pressed, alarm will sound
            if ([node.name isEqualToString:ALARM_BUTTON_NODE_NAME]) {
                _alarmbutton.color = [SKColor grayColor];
                _alarmbutton.alpha = 0.5;
                [self updateState:ALARM];
                [self playAlarm];
                [self checkUserRhythmInput];
                [_controller turnOn];
            }

            break;
        case ALARM:
            break;
        case WAITING:
            if ([node.name isEqualToString:CHARACTER_NODE_NAME]) {
                [_btTransmitter stopAdvertising];
                [self updateState:IDLE];
            }
            break;
        case CONNECTED:
            
            if(velocityY >1000){
                [_controller setInput:@"TAP"];
                [_defaultPlayer.character riseToPositionY:900 ForDuration:(900-location.y)/velocityY];
                [_currentTimeLabel runAction:[SKAction fadeAlphaTo:0.0 duration:0.2]];
                velocityY = 0;
                nodeInTouch = nil;
            }
            else{
                [self resetNoriDrag];
                [_currentTimeLabel runAction:[self clockFadeIn]];
                nodeInTouch = nil;
            }
            break;
        case PLAYING:
            break;
            
        case GAMEOVER:
            break;
        default:
            break;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    switch (_state) {
        case CONNECTED:
            [self resetNoriDrag];
            [_currentTimeLabel runAction:[self clockFadeIn]];
            nodeInTouch = nil;
            break;
        default:
            break;
            
    }
}

-(void)update:(NSTimeInterval)currentTime {
    
    Command *latestCommand;
    
    _currentTimeLabel.text = [AlarmClockModule getCurrentTimeInString];
    
    switch (_state) {
        case IDLE:

            break;
        case SLEEPING:
            
            break;
        case ALARM:
            
            //when the alarm is turned off
            //Character wakes up
            if( _numBeatsToWakeUp == 0){
                [self stopAlarm];
                _numBeatsToWakeUp = 16;
                [_defaultPlayer.character fireAnimationForState:NoriAnimationStateIdle];
                [self updateState:WAITING];
                [_btTransmitter startAdvertising];
                [_controller turnOff];
                break;
            }
            
            if(_isInputTiming){
                if (_controller.enabled) {
                    latestCommand = [_controller update:currentTime];
                    if(latestCommand.input != NEUTRAL && latestCommand.input != TAP && latestCommand.input != START){
                        _numBeatsToWakeUp--;
                        NSLog(@"number of beats to shake: %d", _numBeatsToWakeUp);
                    }
                }
            }
            
            
            break;
        case WAITING:
            if(_btTransmitter.isSubscribed){
                [_controller turnOn];
                [self updateState:CONNECTED];
                [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
                NSLog(@"jump to CONNECTED");
            }
            break;
        case CONNECTED:
            //if central doesnt subscribe to the controller
            if(!_btTransmitter.isSubscribed){
                [_controller turnOff];
                [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                [_defaultPlayer.character dropToPositionY:originalPosition.y ForDuration:0.2];
                [_currentTimeLabel runAction:[self clockFadeIn]];
                [_btTransmitter stopAdvertising];
                [self updateState:IDLE];
                break;
            }

            [self updateCommandAndSend:currentTime];
            break;
        case GAMEOVER:
            break;
        case PLAYING:
            break;
        case MOTIONTEST:
            [self testMotion:currentTime];
            break;
        default:
            break;
    }
    
}

-(void)updateCommandAndSend:(NSTimeInterval) currentTime{
    
    //first get the latest command
    [_controller update:currentTime];
    
    if (_btTransmitter.isSubscribed && _controller.enabled) {
        if( _controller.triggeredCommand.input != NEUTRAL){
            _btTransmitter.dataToSend = [[_controller.triggeredCommand inputInString] dataUsingEncoding:NSUTF8StringEncoding];
            [_btTransmitter sendData];
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

-(void)resetNoriDrag{
    if(nodeInTouch){
        nodeInTouch = nil;
        lastTimeStamp = 0.0;
        lastY = 0.0;
        [_defaultPlayer.character dropToPositionY:originalPosition.y ForDuration:0.2];
    }
}

-(SKAction *)clockFadeIn{
    SKAction *lower = [SKAction moveToY:500.0 duration:0.5];
    SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.5];
    return [SKAction group:@[lower,alpha]];
}

-(void)checkUserRhythmInput{
    [ self runAction:[SKAction repeatAction:[self checkInputSequence] count:8] ];
}

-(SKAction *)checkInputSequence{
    return [SKAction sequence:@[
                                
                                [SKAction waitForDuration:GOOD_TIMING_DELTA],
                                
                                [SKAction runBlock:^{_isInputTiming = NO;}],
                                [SKAction waitForDuration:_secPerBeat - GOOD_TIMING_DELTA*2],
                                
                                [SKAction runBlock:^{_isInputTiming = YES;}],
                                [SKAction waitForDuration:GOOD_TIMING_DELTA],
                                ]
            ];
}

-(void)updateState: (iOSGameState)state{
    
    switch (_state) {
        case IDLE:
            break;
        case SLEEPING:
            break;
        case ALARM:
            break;
        case WAITING:
            [_defaultPlayer.character turnOffSearchLight];
            break;
        case CONNECTED:
            break;
        default:
            break;
    }
    
    switch (state) {
        case IDLE:
            _statusLabel.text = @"Tap To Get Ready";
            break;
        case SLEEPING:
            _statusLabel.text = @"Zzzz...";
            break;
        case ALARM:
            _statusLabel.text = @"Give Me Some Rhythm Please...";
            break;
        case WAITING:
            _statusLabel.text = @"Looking For Launch Point";
            [_defaultPlayer.character turnOnSearchLight];
            break;
        case CONNECTED:
            _statusLabel.text = @"Slide Me UP!";
            [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReady];
            break;
        default:
            break;
    }
    _state = state;
}

@end
