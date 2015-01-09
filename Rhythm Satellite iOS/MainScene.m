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


#define ALARM_KEY @"alarmkey"
#define NUM_TO_WAKE 24

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
CGPoint             originalCharacterPosition;
CGPoint             originalClockPosition;
CGFloat             velocityY;
BOOL                alarmChanging;
SKTextureAtlas      *messageAtlas;

@interface MainScene()

@property (nonatomic, strong) BTPeripheralModule            *btTransmitter;
@property (nonatomic, strong) BTCentralModule            *btReceiver;
@property (nonatomic, strong) MotionControllerModule        *controller;
@property (nonatomic, strong) AlarmClockModule              *alarm;
@property (nonatomic) iOSGameState                          state;
@property (nonatomic, readonly) int                         numBeatsToWakeUp;
@property (nonatomic) int                                   numBeatsHit;
@property (nonatomic) Player                                *defaultPlayer;
@property (nonatomic) SKLabelNode                           *currentTimeLabel;
@property (nonatomic) SKLabelNode                           *assemblyLabel;
@property (nonatomic) SKLabelNode                           *alarmTimeLabel;
@property (nonatomic) SKSpriteNode                          *alarmbutton;
@property (nonatomic) SKSpriteNode                          *mainbutton;
@property (nonatomic) SKSpriteNode                          *demobutton;
@property (nonatomic) SKSpriteNode                          *messageSprite;
@property (nonatomic, strong)SKSpriteNode                   *uiNode;
@property (nonatomic) float                                 secPerBeat;
@property (nonatomic) BOOL                                  isInputTiming;
@property (nonatomic) BOOL                                  isAssemblyTime;


@end

#define MAX_CLOCK_Y 600


@implementation MainScene

-(void)didMoveToView:(SKView *)view {
    
    if(!_btTransmitter){
        _btTransmitter = iOSUIAppDelegate.btTransmitter;
    }
    
    if(!_btReceiver){
        _btReceiver = iOSUIAppDelegate.btReceiver;
    }
    
    if(!_controller){
        _controller = [[MotionControllerModule alloc]init];
    }
    
    _uiNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.15 green:0.19 blue:0.31 alpha:1.0] size:CGSizeMake(self.size.width * 3.0, self.size.height)];

    _uiNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    originalCharacterPosition = CGPointMake(0.0, -200.0);
    
    
    
    //mainplayer
    if (!_defaultPlayer) {
        _defaultPlayer = [[Player alloc]initWithPlayerName:@"Kiron"];
        _defaultPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:30 withDef:15 withMoney:1000 onTheRight:nil];
        _defaultPlayer.character.position = originalCharacterPosition;
        [_defaultPlayer.character fireAnimationForState:NoriAnimationStateIdle];
        [_defaultPlayer.character setScale:1.1];
        _defaultPlayer.character.userInteractionEnabled = NO;
        [_uiNode addChild:_defaultPlayer.character];
        
    }

    _alarm = [[AlarmClockModule alloc]init];
    _alarm.hour = 7;
    _alarm.minute = 0;
    
//    //Current Time Label
//    _currentTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
//    _currentTimeLabel.text = [AlarmClockModule getCurrentTimeInString];
//    _currentTimeLabel.fontSize = 30;
//    _currentTimeLabel.position = originalClockPosition;
//    _currentTimeLabel.zPosition = 10;
//    [_uiNode addChild:_currentTimeLabel];
    
    //Assembly Time Label
    _assemblyLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
    _assemblyLabel.text = @"Assembly Time";
    _assemblyLabel.fontSize = 30;
    _assemblyLabel.position = CGPointMake(-self.size.width, 100.0);;
    _assemblyLabel.zPosition = 10;
    [_uiNode addChild:_assemblyLabel];
    
    
    
    
    //Alarm Time Label
    _alarmTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
    _alarmTimeLabel.text = @"07:00";
    _alarmTimeLabel.fontSize = 80;
    _alarmTimeLabel.position = CGPointMake(-self.size.width, 0.0);
    [_uiNode addChild:_alarmTimeLabel];
    
    //alarm button
    _alarmbutton = [SKSpriteNode spriteNodeWithImageNamed:@"alarmicon"];
    _alarmbutton.position = CGPointMake(-self.size.width/2 + _alarmbutton.size.width/2+5, -self.size.height/2 + _alarmbutton.size.height/2+5);
    [_uiNode addChild:_alarmbutton];
    
    //main button
    _mainbutton = [SKSpriteNode spriteNodeWithImageNamed:@"headbutton"];
    _mainbutton.position = CGPointMake(-self.size.width/2 - _alarmbutton.size.width/2-10, -self.size.height/2 + _alarmbutton.size.height/2+5);
    [_uiNode addChild:_mainbutton];
    
    //demo button
    _demobutton = [SKSpriteNode spriteNodeWithImageNamed:@"demobutton"];
    _demobutton.position = CGPointMake(self.size.width/2 - _demobutton.size.width/2-10, 0.0);
    [_uiNode addChild:_demobutton];
    
    
    //attributes setup
    _secPerBeat = 60.0/120.0;
    _numBeatsToWakeUp = NUM_TO_WAKE;
    _numBeatsHit = 0;
    _isInputTiming = NO;
    _isAssemblyTime = NO;
    
    messageAtlas = [SKTextureAtlas atlasNamed:@"Message"];
    
    _messageSprite = [SKSpriteNode spriteNodeWithTexture:[messageAtlas textureNamed:@"message_idle"]];
    _messageSprite.position = CGPointMake(0.0,120.0);
//    _messageSprite.alpha = 0.0;
    [_uiNode addChild:_messageSprite];
    
    [self addChild:_uiNode];

    [self updateState:IDLE];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_uiNode];
    
    
    switch (_state) {
            
        case IDLE:
            if([_alarmTimeLabel containsPoint:location]){
                alarmChanging = YES;
                lastY = location.y;
            }

            break;
            
        case CONNECTED:
            if ([_defaultPlayer.character containsPoint:location]) {
                lastY = location.y;
                lastTimeStamp = event.timestamp;
                nodeInTouch = _defaultPlayer.character;
            }
            break;
        default:
            break;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_uiNode];
    
    if(alarmChanging){
        int difference = location.y - lastY;
        int steps = difference/20;
        if( abs(steps) > 0 ){
            lastY = location.y;
        }
//        NSLog(@"steps %d", steps);
        
        _alarm.minute += steps*15;
        if (_alarm.minute < 0) {
            _alarm.minute = 45;
            _alarm.hour --;
            if (_alarm.hour <= 4){
                _alarm.hour = 0;
                _alarm.minute = 0;
            }
        }
        else if (_alarm.minute > 59) {
            _alarm.minute = 0;
            _alarm.hour ++;
            if (_alarm.hour > 9){
                _alarm.hour = 9;
                _alarm.minute = 45;
            }
        }
        else if (_alarm.hour == 0 && _alarm.minute == 15){
            _alarm.hour = 5;
            _alarm.minute = 0;
        }
        
        
        if (_alarm.hour == 0) {
            _alarmTimeLabel.text = @"OFF";
        }
        else{
            _alarmTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", _alarm.hour, _alarm.minute];
        }
    }
    
    switch (_state) {
        case CONNECTED:
            if (nodeInTouch) {
                CGFloat distance = location.y - lastY;
                
                //avoid dropping lower than the original position
                if (nodeInTouch.position.y < originalCharacterPosition.y) {
                    nodeInTouch.position = CGPointMake(nodeInTouch.position.x, originalCharacterPosition.y);
                    distance = 0.0;
                }
                else{
                    nodeInTouch.position = CGPointMake(nodeInTouch.position.x, nodeInTouch.position.y + distance);
                }
                
//                CGFloat alpha = (MAX_CLOCK_Y - _defaultPlayer.character.position.y)/(MAX_CLOCK_Y - originalCharacterPosition.y);
//                [_currentTimeLabel setAlpha:alpha];
//                _currentTimeLabel.position = CGPointMake(_currentTimeLabel.position.x, _currentTimeLabel.position.y + distance/20.0);
//                
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
    CGPoint location = [touch locationInNode:_uiNode];

    
    //when the alarm time has changed
    if(alarmChanging){
        alarmChanging = NO;
        
        //setting alarm
        if(_alarm.hour != 0){
            [_alarm setAlarm];
        }
        else{
            [_alarm switchOffAlarm];
        }
    }
    
    switch (_state) {
        case IDLE:
            //alarm button is pressed
            //character will go to sleep
            if ([_alarmbutton containsPoint:location]) {
//                if(_alarm.alarmState == alarmOff){
//                    [_alarm switchOnAlarm];
//                    _alarmbutton.color = [SKColor whiteColor];
//                    _alarmbutton.alpha = 1.0;
//                    //changing state
//                    [self updateState:SLEEPING];
//                }
                [_uiNode runAction:[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame)+self.size.width, CGRectGetMidY(self.frame)) duration:0.2]];
            }
            
            //the character is pressed
            if ( [_defaultPlayer.character containsPoint:location] && _btTransmitter) {
                [_btTransmitter startAdvertising];
                [self updateState:WAITING];
            }
            
            //main menu button is pressed
            if ([_mainbutton containsPoint:location]) {
                [_uiNode runAction:[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2]];
            }
            
            //demo button is pressed
            if ([_demobutton containsPoint:location]) {
                [self updateState:SLEEPING];
            }
            
            break;
        case SLEEPING:
            //demo button is pressed
            if ([_demobutton containsPoint:location]) {
                [self updateState:ALARM];
            }

            break;
        case ALARM:
            break;
        case WAITING:
            if ([_defaultPlayer.character containsPoint:location]) {
                [_btTransmitter stopAdvertising];
                [self updateState:IDLE];
            }
            break;
        case CONNECTED:
            
            if(velocityY >1000){
                [_controller setInput:@"START"];
                [_defaultPlayer.character riseToPositionY:900 ForDuration:(900-location.y)/velocityY];
                [_currentTimeLabel runAction:[SKAction fadeAlphaTo:0.0 duration:0.2]];
                velocityY = 0;
//                NSLog(@"%@", [_controller.triggeredCommand inputInString]);
                //dont know why, but the sending does not work to wait until update loop
                _btTransmitter.dataToSend = [[_controller.triggeredCommand inputInString] dataUsingEncoding:NSUTF8StringEncoding];
                [_btTransmitter sendData];
            }
            else{
                [_controller setInput:@"TAP"];
                [self resetNoriDrag];
                [_currentTimeLabel runAction:[self fadeIn]];
            }
            nodeInTouch = nil;
            break;
        case PLAYING:
            break;
            
        case GAMEOVER:
            break;
        default:
            break;
    }
    
    lastY = -1.0;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    switch (_state) {
        case CONNECTED:
            [self resetNoriDrag];
            [_currentTimeLabel runAction:[self fadeIn]];
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
            if(_alarm.alarmState == alarmOn){
                if ([_alarm.alarmDate timeIntervalSinceDate:[NSDate date]] <= 0 ) {
                    [self updateState:ALARM];
                }
            }
            break;
        case ALARM:
            
            //when the alarm is turned off
            //Character wakes up
            if( _numBeatsToWakeUp == 0){
                
                _numBeatsToWakeUp = NUM_TO_WAKE;
                
                [self updateState:IDLE];
                break;
            }
            
            if(_isInputTiming){
                if (_controller.enabled) {
                    latestCommand = [_controller update:currentTime];
                    if(latestCommand.input != NEUTRAL && latestCommand.input != TAP && latestCommand.input != START){
                        _numBeatsToWakeUp--;
                        [_defaultPlayer.character voiceForCommand:DOWN];
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
                [_defaultPlayer.character dropToPositionY:originalCharacterPosition.y ForDuration:0.2];
                [_currentTimeLabel runAction:[self fadeIn]];
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
        [_defaultPlayer.character dropToPositionY:originalCharacterPosition.y ForDuration:0.2];
    }
}

-(SKAction *)fadeIn{
//    SKAction *lower = [SKAction moveToY:originalClockPosition.y duration:0.5];
//    SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.5];
//    return [SKAction group:@[lower,alpha]];
    return [SKAction fadeAlphaTo:1.0 duration:0.5];
}

-(void)startCheckingUserRhythmInput{
//    [ self runAction:[SKAction repeatAction:[self checkInputSequence] count:8] ];
    [ self runAction:[SKAction repeatActionForever:[self checkInputSequence] ] withKey:ALARM_KEY];
    _isInputTiming = YES;
}

-(void)stopCheckingUserRhythmInput{
    [self removeActionForKey:ALARM_KEY];
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
    
    //previous state
    switch (_state) {
        case IDLE:
            break;
        case SLEEPING:
            break;
        case ALARM:
            
            //turn off the music alarm
            [_alarm stopAlarm];
            
            //switch off the alarm
            [_alarm switchOffAlarm];
            
            [_controller turnOff];
            [self stopCheckingUserRhythmInput];
            [_defaultPlayer.character fireAnimationForState:NoriAnimationStateIdle];
            _isAssemblyTime = YES;
            break;
        case WAITING:
            [_defaultPlayer.character turnOffSearchLight];
            break;
        case CONNECTED:
            break;
        default:
            break;
    }
    
    //new state
    switch (state) {
        case IDLE:
            [_defaultPlayer.character fireAnimationForState:NoriAnimationStateIdle];
            break;
        case SLEEPING:
            [_defaultPlayer.character fireAnimationForState:NoriAnimationStateSleeping];
            break;
        case ALARM:
            [_defaultPlayer.character fireAnimationForState:NoriAnimationStateSleepy];
            [_controller turnOn];
            [self startCheckingUserRhythmInput];
            [_alarm playAlarm];
            NSLog(@"Alarm!!!!!!");
            break;
        case WAITING:
            [_defaultPlayer.character turnOnSearchLight];
            break;
        case CONNECTED:
            [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReady];
            break;
        default:
            break;
    }
    
    NSLog(@"Switching from %u to %u", _state, state);
    
    _state = state;
    
    [self displayMessage];
}

-(void)displayMessage{
    switch (_state) {
        case IDLE:
            if (_isAssemblyTime) {
                //bring me to assembly
                [_messageSprite setTexture:[messageAtlas textureNamed:@"message_afterwakeup"]];
            }
            else{
                //tap me to get ready
                [_messageSprite setTexture:[messageAtlas textureNamed:@"message_idle"]];
            }
            break;
        case SLEEPING:
            [_messageSprite setTexture:[messageAtlas textureNamed:@"message_sleeping"]];
            break;
        case ALARM:
            [_messageSprite setTexture:[messageAtlas textureNamed:@"message_alarm"]];
            break;
        case WAITING:
            [_messageSprite setTexture:[messageAtlas textureNamed:@"message_waiting"]];
            break;
        case CONNECTED:
            [_messageSprite setTexture:[messageAtlas textureNamed:@"message_connected"]];
            break;
        default:
            break;
    }
    
    SKAction* show = [SKAction fadeAlphaTo:1.0 duration:0.1];
    SKAction* wait = [SKAction waitForDuration:5.0];
    SKAction* fadeout = [SKAction fadeAlphaTo:0.0 duration:1.0];
    SKAction* display = [SKAction sequence:@[show, wait, fadeout]];
    [_messageSprite removeAllActions];
    _messageSprite.alpha = 0.0;
    [_messageSprite runAction:display];
    
//    NSLog(@"asdf!");
}


@end
