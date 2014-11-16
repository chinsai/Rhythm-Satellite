//
//  BattleScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/09.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "BattleScene.h"
#import <AVFoundation/AVFoundation.h>
#import "CommandNote.h"
#import "Action.h"
#import "Command.h"

#import "OSXAppDelegate.h"

#define errorTolerance 0.2
#define GoSoundKey @"gosound"
#define InputAndAnimationKey @"inputandanimation"

typedef enum : uint8_t {
    SCANNING,
    SEARCHING,
    WAITING,
    READY,
    PLAYING,
    ENDED,
    GRAPHICSTEST
} BattleState;

typedef enum : uint8_t {
    FreePlayBattle,
    TournamentBattle
}   GameMode;

NSTimeInterval      timeElapsed;
NSTimeInterval      previousTime;
int                 numOfReadyRound;
NSTimeInterval      lastCommandTiming;
NSTimeInterval      beatTick;
int                 warmUpBeats;
BOOL                beatTiming;
BOOL                warmUp;


@interface BattleScene()

@property (nonatomic, strong) NSArray               *players;

@property (nonatomic, strong) Player                *defaultPlayer;
@property (nonatomic, strong) Player                *opponentPlayer;

@property (nonatomic, strong) SKSpriteNode          *background;

@property (nonatomic, strong) NSMutableArray        *inputCommands;

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

@property (nonatomic) BattleState                   gameState;

@end



@implementation BattleScene

-(void)didMoveToView:(SKView *)view {
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
    _inputCommands = [[NSMutableArray alloc]init];
    
    //music player
    [self setUpMusicPlayer];
    if (!_defaultPlayer) {
        _defaultPlayer = [[Player alloc]initWithPlayerName:@"Kiron"];
        _defaultPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:20 withDef:5 withMoney:1000];
        _defaultPlayer.character.position = CGPointMake(CGRectGetMidX(self.frame)-300, CGRectGetMidY(self.frame)-100);
        [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReady];
        [self addChild:_defaultPlayer.character];

    }
    
    _opponentPlayer = [[Player alloc]initWithPlayerName:@"OIKOS"];
    _opponentPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:20 withDef:5 withMoney:1000];
    _opponentPlayer.character.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame)-100);
    [_opponentPlayer.character fireAnimationForState:NoriAnimationStateReady];
    [self addChild:_opponentPlayer.character];

    
    
    
    _btReceiver = NSAppDelegate.btReceiver;
    _isInputTiming = NO;
    _secPerBeat = 60.0/120.0;
    _numOfRounds = 0;
    _gameState = SCANNING;

    timeElapsed = 0;
    previousTime = 0;
    numOfReadyRound = 1;
    beatTiming = NO;
    warmUp = YES;
}

-(void)update:(NSTimeInterval)currentTime{
    
    if(previousTime == 0)
        previousTime = currentTime;
    
    
    //update the command input
    Command* latestCommand = [self getLatestCommand];;
    
    switch (_gameState) {
        case SCANNING:
            //if there is peripheral connected
            if(_btReceiver.hasConnectedPeripheral){
                _gameState = READY;
                NSLog(@"go to READY");
            }
            break;
        case SEARCHING:
            break;
        case WAITING:
            break;
        case READY:
            //update the command input to look for a TAP command
            if (latestCommand.input == TAP) {
                [self startBattle];
                NSLog(@"go to PLAYING");
            }
            break;
            
        case PLAYING:

            timeElapsed += currentTime - previousTime;

            if(warmUp){
                break;
            }
            
            //if all the rounds are finished
            if( _numOfRounds == 0){
                timeElapsed = 0;
                previousTime = 0;
                _gameState = SCANNING;
                [self removeActionForKey:GoSoundKey];
                [self removeActionForKey:InputAndAnimationKey];
                break;
            }
            
            //when is is the turn for player to input command
            if(_isInputTiming){
//                NSLog(@"user input");
                
                
                
                int commandNumber = timeElapsed/_secPerBeat;
                float inputTimingError = timeElapsed - commandNumber*_secPerBeat;
                
                //remove negative number, get absolute value
                if ( inputTimingError < 0){
                    inputTimingError = -inputTimingError;
                }

                
                //CHECK INPUT
                if( latestCommand.input == NEUTRAL ){
                    //if no input
                    
                    
                    if ( timeElapsed > commandNumber*_secPerBeat + errorTolerance) {
                        //failed to input on time
                        // inputFailed = YES;
                        
                    }
                    break;
                }
                else{
                    //show animation of input
                    [_defaultPlayer.character takeCommand:latestCommand.input];
                    
                    if( inputTimingError <= errorTolerance){
                        NSLog(@"successful input");
                        [_inputCommands addObject:latestCommand];
                        
                        //if there are 4 commands, create an action for the character
                        if( [_inputCommands count] == 4){
                            _defaultPlayer.character.nextAction = [Action retrieveActionFrom:_inputCommands];

                        }
                    }
                    
                }
                
                
                break;
                
            }
            
            //when it is not the time for player commands
            else {
                
//                NSLog(@"for showing result");
                
                if( timeElapsed == _secPerBeat*0 && beatTiming){
                    //start of the animation period
                    
                    //if defaultplayer has the input
                    if(_defaultPlayer.character.nextAction){
                        NSLog(  @"Perform Action: %@",[_defaultPlayer.character.nextAction toString] );
                        _defaultPlayer.character.nextAction = nil;
                    }
                    
                }
              
            }
            
            break;
            
        case ENDED:
            break;
        case GRAPHICSTEST:
            [self startBattle];
            break;
        default:
            break;
    }
    
    previousTime = currentTime;
    
    
}

-(void)startBattle{
    _gameState = PLAYING;

    [self resetBattle];
    
    //play the music once it starts
    [_musicPlayer play];
    
    //Loop for GO signal
    SKAction *go = [SKAction sequence:@[
                                        [SKAction waitForDuration:_secPerBeat*7],
                                        [SKAction playSoundFileNamed:@"Go.m4a" waitForCompletion:NO],
                                        [SKAction waitForDuration:_secPerBeat]
                                        ]
                     ];
    
    [self runAction:[SKAction repeatActionForever:go] withKey:GoSoundKey];
    
    
    SKAction *performAnimation =
    [SKAction runBlock:^(void){
        if(_defaultPlayer.character.nextAction){
            NSLog(  @"Perform Action: %@",[_defaultPlayer.character.nextAction toString] );
            _defaultPlayer.character.nextAction = nil;
        }
    }];
    
    //startoff with Warmup Beats
    [self runAction:[SKAction waitForDuration:_secPerBeat*8] completion: ^(void){
        warmUp = NO;
        //start main loop
        SKAction *inputAndAnimationLoop = [SKAction sequence:@[
                                                               [SKAction runBlock: ^(void){_isInputTiming = YES;
                                                                                            timeElapsed = 0;
                                                                                            _isInputTiming = YES;
                                                                                            //clear out input commands
                                                                                            [_inputCommands removeAllObjects];}],
                                                               
                                                               [SKAction waitForDuration:_secPerBeat*4],
                                                               
                                                               [SKAction runBlock: ^(void){_isInputTiming = NO;
                                                                                            timeElapsed = 0;
                                                                                            _isInputTiming = NO;
                                                                                            _numOfRounds --;}],
                                                               
                                                               performAnimation,
                                                               
                                                               [SKAction waitForDuration:_secPerBeat*4]
                                                               
                                                               ]
                                           ];
        
        
        [self runAction:[SKAction repeatActionForever:inputAndAnimationLoop] withKey:InputAndAnimationKey];
    }];

    
    
    
    
}

-(void)resetBattle{
    //reset the attribute
    _numOfRounds = 16;
    timeElapsed = 0;
    previousTime = 0;
    beatTick = _secPerBeat*0.98;
    warmUpBeats = 8;
    beatTiming = NO;
    _isInputTiming = YES;
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

-(void)transferPlayer:(Player*)player{
    if (player) {
        _defaultPlayer = player;
        [_defaultPlayer.character setScale:1.00f];
         _defaultPlayer.character.position = CGPointMake(CGRectGetMidX(self.frame)-300, CGRectGetMidY(self.frame)-100);
        [_defaultPlayer.character removeFromParent];
        [self addChild:_defaultPlayer.character];
    }
}


-(void)setUpMusicPlayer{
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"RS1" withExtension:@"m4a"];
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _musicPlayer.numberOfLoops = 0;
    [_musicPlayer prepareToPlay];
}

@end