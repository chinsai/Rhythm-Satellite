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


typedef enum assemblyStateType{
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


@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// array of character stage
@property (nonatomic, strong) NSMutableArray        *characters;

// background
@property (nonatomic, strong) SKSpriteNode          *background;

// cover
@property (nonatomic, strong) SKSpriteNode          *cover;

// timing rank label
@property (nonatomic, strong) SKLabelNode          *greatLabel;

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

    _greatLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _greatLabel.text = @"SCORE";
    _greatLabel.fontSize = 24;
    _greatLabel.position = CGPointMake(CGRectGetMidX(self.frame), 500);
    [self addChild:_greatLabel];

    
    tempCharacter = [SKSpriteNode spriteNodeWithImageNamed:@"nori_nod_0001"];
    tempCharacter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100);
    [self addChild:tempCharacter];
    
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

}


-(void)update:(NSTimeInterval)currentTime{
    
    if(previousTime == 0)
        previousTime = currentTime;
    
    
    
    Command* latestCommand;
    
    switch (gameState) {
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
                    _greatLabel.text = @"CANT INPUT NOW";
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
//                    [self runAction:[SKAction playSoundFileNamed:@"Ready.m4a" waitForCompletion:NO]];
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
                    if (currentTime - lastCommandTiming < 0.2) {
                        latestCommand.input = NEUTRAL;
                        break;
                    }
                    lastCommandTiming = currentTime;
                    NSLog(@"the gesture is %@", [latestCommand inputInString]);
                    
    
                }
                
                if( targetCommand.input == latestCommand.input && inputTimingError <= GOOD_TIMING_DELTA){
                    
                    //successful input
                    if(inputTimingError<=GREAT_TIMING_DELTA){
                        [targetNote changeToGreatTiming];
                    }
                    else{
                        [targetNote changeToGoodTiming];
                    }
                    NSLog(@"input ok with Error %f", inputTimingError);
                    NSLog(@"target: %d, input: %d", targetCommand.input, latestCommand.input);
                    
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
                    _greatLabel.text = @"INPUT NOW";
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
                }
                
            }
            
            break;
            
        case ENDED:
            break;
        case GRAPHICSTEST:
            [self startGame];
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
