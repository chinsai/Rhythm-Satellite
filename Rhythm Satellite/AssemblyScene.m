//
//  AssemblyScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AssemblyScene.h"
#import <AVFoundation/AVFoundation.h>
#import "BTCentralModule.h"
#import "BTPeripheralModule.h"
#import "CommandNote.h"
#import "Action.h"
#import "Command.h"
#import "Player.h"
#import <HueSDK_OSX/HueSDK.h>

#define MAX_HUE 65536

typedef enum assemblyStateType{
    SETUP,
    SCANNING,
    SEARCHING,
    WAITING,
    READY,
    PLAYING,
    ENDED,
    GRAPHICSTEST
} AssemblyState;


NSTimeInterval      timeElapsed;
NSTimeInterval      previousTime;
AssemblyState       gameState;
SKSpriteNode        *tempCharacter;
int                 numOfReadyRound;
BOOL                readyFlag;
NSTimeInterval      lastCommandTiming;
PHBridgeResourcesCache *cache;
NSArray *lights;
PHBridgeSendAPI *bridgeSendAPI;

@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// array of character stage
@property (nonatomic, strong) NSArray               *characters;

@property (nonatomic, strong) NSArray               *players;

@property (nonatomic, strong) Player                *defaultPlayer;
// background
@property (nonatomic, strong) SKSpriteNode          *background;

// cover
@property (nonatomic, strong) SKSpriteNode          *cover;


@property (nonatomic, strong) NSMutableArray        *inputCommands;
@property (nonatomic, strong) NSArray               *commandNotes;

// music
@property (nonatomic, strong) AVAudioPlayer         *musicPlayer;

// BLE Central
@property (nonatomic, strong) BTCentralModule       *btReceiver;

// Input timing or not
@property (nonatomic) BOOL                          isInputTiming;

// Second per beat
@property (nonatomic) float                         secPerBeat;

// Number of Rounds left
@property (nonatomic) int                           numOfRounds;

@property (nonatomic, strong) Action                *targetAction;

@end



@implementation AssemblyScene


-(void)didMoveToView:(SKView *)view {

    _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
    _inputCommands = [[NSMutableArray alloc]init];
    _commandNotes = [NSArray arrayWithObjects:
                     [[CommandNote alloc] initWithDirection:NEUTRAL ],
                     [[CommandNote alloc] initWithDirection:NEUTRAL ],
                     [[CommandNote alloc] initWithDirection:NEUTRAL ],
                     [[CommandNote alloc] initWithDirection:NEUTRAL ],nil];
    CommandNote *a = _commandNotes[0];
    float margin = 30;
    float notestartx = CGRectGetMidX(self.frame) - (a.size.width + margin)*3/2;
    float notestarty = 600;
    
    for (int i = 0 ; i < 4 ; i++) {
        CommandNote *a = _commandNotes[i];
        a.position = CGPointMake(notestartx + (margin + a.size.width)*i, notestarty);
        [self addChild:a];
    }
    
    _defaultPlayer = [[Player alloc]initWithPlayerName:@"Kiron"];
    _players = [NSArray arrayWithObjects:_defaultPlayer, nil];
    _defaultPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:20 withDef:5 withMoney:1000];
    _defaultPlayer.character.position = CGPointMake(200, CGRectGetMidY(self.frame)-100);
    [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReady];
    [self addChild:_defaultPlayer.character];
    
    
    
    //music player
    [self setUpMusicPlayer];

    _btReceiver = [[BTCentralModule alloc] init];
    _isInputTiming = NO;
    _secPerBeat = 60.0/120.0;
    _numOfRounds = 16;
    
    gameState = SCANNING;
    timeElapsed = 0;
    previousTime = 0;
    numOfReadyRound = 1;
    readyFlag = NO;

    
    bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
}


-(void)update:(NSTimeInterval)currentTime{
    
    if(previousTime == 0)
        previousTime = currentTime;
    
    
    
    Command* latestCommand;
    
    switch (gameState) {
        case SETUP:
            break;
        case SCANNING:
            //if there is peripheral connected
            if(_btReceiver.hasConnectedPeripheral){
                gameState = READY;
                NSLog(@"go to READY");
            }
            
            break;
        case SEARCHING:
            break;
        case WAITING:
            break;
        case READY:
            //update the command input to look for a TAP command
            latestCommand = [self getLatestCommand];
            if (latestCommand.input == TAP) {
                [self startGame];
//                gameState = GRAPHICSTEST;
                NSLog(@"go to PLAYING");
            }
            
            break;
            
        case PLAYING:
            
            
            timeElapsed += currentTime - previousTime;
//            NSLog(@"timeElapsed: %f, SecPerBeat: %f, RoundsLeft: %d", timeElapsed, _secPerBeat, _numOfRounds);
            
            //update the command input
            latestCommand = [self getLatestCommand];
            
            //if all the rounds are finished
            if( _numOfRounds == 0){
                [_btReceiver cleanup];
                [_btReceiver scan];
                timeElapsed = 0;
                previousTime = 0;
                gameState = SCANNING;
                break;
            }
            
            //when is is the turn for player to input command
            if(_isInputTiming){
                
                //when finish one round of 4 beats
                if(timeElapsed >= _secPerBeat*3.98){
                    timeElapsed = 0;
                    _isInputTiming = NO;
                    _numOfRounds --;
                    //reset the notes to all gray
                    for (CommandNote* note in _commandNotes) {
                        note.isActive = NO;
                        [note changeToNeutral];
                    }
                    //random the next target action
                    if(!_targetAction){
                        _targetAction = [[Action alloc]initWithRandomAction];
                    }
                    else{
                        [_targetAction randomAction];
                    }
                
                    break;
                }
                
                
                if(timeElapsed >= _secPerBeat *3 && !readyFlag){
                    readyFlag = YES;
                }
                    
                int commandNumber = timeElapsed/_secPerBeat;
                float inputTimingError = timeElapsed - commandNumber*_secPerBeat;
                
                //remove negative number, get absolute value
                if ( inputTimingError < 0){
                    inputTimingError = -inputTimingError;
                }
                
                Command *targetCommand = _targetAction.commands[commandNumber];
                CommandNote *targetNote = _commandNotes[commandNumber];
                
                if( latestCommand.input == NEUTRAL ){
                    //if no input
                    
                    
                    if ( timeElapsed > commandNumber*_secPerBeat + GOOD_TIMING_DELTA) {
                        //failed to input on time
//                            inputFailed = YES;
                        
                    }
                    break;
                }
                else{
                    
                    //if there is command, change characters animations
                    [_defaultPlayer.character takeCommand:latestCommand.input];
                    
                    if (currentTime - lastCommandTiming < 0.2) {
                        latestCommand.input = NEUTRAL;
                        break;
                    }
                    lastCommandTiming = currentTime;
                
                
                    if( targetCommand.input == latestCommand.input && inputTimingError <= GOOD_TIMING_DELTA){
                        
                        //successful input
                        if(inputTimingError<=GREAT_TIMING_DELTA){
                            [targetNote changeToGreatTiming];
                        }
                        else{
                            [targetNote changeToGoodTiming];
                        }
                        
    //                    cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    //                    // And now you can get any resource you want, for example:
    //                    lights = [cache.lights allValues];
    //                    [((PHLight *)lights[0]).lightState setTransitionTime:0];
    ////                    [((PHLight *)lights[0]).lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
    //                    [((PHLight *)lights[0]).lightState setHue:[NSNumber numberWithInt:25500]];
    //                    [((PHLight *)lights[0]).lightState setBrightness:[NSNumber numberWithInt:128]];
    //                    [((PHLight *)lights[0]).lightState setSaturation:[NSNumber numberWithInt:254]];
    //                    
    //                    
    //                    [bridgeSendAPI updateLightStateForId:((PHLight *)lights[0]).identifier withLightState:((PHLight *)lights[0]).lightState completionHandler:^(NSArray *errors) {
    //                        if (!errors){
    //                            // Update successful
    //                        } else {
    //                            // Error occurred
    //                        }
    //                    }];
                        
                        NSLog(@"input ok with Error %f", inputTimingError);
                        NSLog(@"target: %d, input: %d", targetCommand.input, latestCommand.input);
                        
                    }
                    else{
    //                    cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    //                    // And now you can get any resource you want, for example:
    //                    lights = [cache.lights allValues];
    //                    
    //                    if( !((PHLight *)lights[0]).lightState.on )
    //                        break;
    //                    [((PHLight *)lights[0]).lightState setTransitionTime:0];
    //                    //                    [((PHLight *)lights[0]).lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
    //                    [((PHLight *)lights[0]).lightState setOn:false];
    //                    
    //                    
    //                    [bridgeSendAPI updateLightStateForId:((PHLight *)lights[0]).identifier withLightState:((PHLight *)lights[0]).lightState completionHandler:^(NSArray *errors) {
    //                        if (!errors){
    //                            // Update successful
    //                        } else {
    //                            // Error occurred
    //                        }
    //                    }];
                        
                    }
                }
                break;
                
            }
            
             //when it is not the time for player commands
            else {
                //if its time for switch
                if(timeElapsed >= _secPerBeat*3.98){
                    timeElapsed = 0;
                    _isInputTiming = YES;
                    for (CommandNote* note in _commandNotes) {
                        note.isActive = YES;
                    }
                    break;
                }
                
                if(timeElapsed >= _secPerBeat *2.7 && readyFlag){
                    [self runAction:[SKAction playSoundFileNamed:@"Go.m4a" waitForCompletion:NO]];
                    readyFlag = NO;
                }
                
                //show the commands that the player has to follo
                    
                int beatNumber = timeElapsed/_secPerBeat;
                CommandNote *note = _commandNotes[beatNumber];
                if (note.isChangable){
                    [note changeTo:((Command*)_targetAction.commands[beatNumber]).input];
                    
                    //avoid unnecessary graphic updates
                    note.isChangable = NO;
                    int prevNumber = beatNumber - 1;
                    if(prevNumber < 0)
                        prevNumber = 3;
                    ((CommandNote*)_commandNotes[prevNumber]).isChangable = YES;
                    
                    //character nodding according to the beat
                    [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReadyNod];
                }
                
            }
            
            break;
            
        case ENDED:
            break;
        case GRAPHICSTEST:
            
            if (latestCommand.input == TAP) {
                // Get the cache
                
            }
            
            break;
        default:
            break;
    }

    previousTime = currentTime;

    
}

-(void)startGame{
    gameState = PLAYING;
    
    //reset the attribute
    _numOfRounds = 16;
    timeElapsed = 0;
    previousTime = 0;
    
    //todo
    //reset the command notes
    [_targetAction setActionWithType:NONE];
    
    //play the music once it starts
    [_musicPlayer play];
    
}

-(Command *)getLatestCommand{
    
    Command *command;
    
    if(_btReceiver.receivedData.length != 0){
        NSString *stringFromData = [[NSString alloc] initWithData:_btReceiver.receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", stringFromData);
        command = [[Command alloc] initWithString:stringFromData];
        [_btReceiver.receivedData setLength:0];
    }
    return command;
}

-(void)setUpMusicPlayer{
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"RS1" withExtension:@"m4a"];
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _musicPlayer.numberOfLoops = 0;
    [_musicPlayer prepareToPlay];
}

@end
