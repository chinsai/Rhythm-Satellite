//
//  AssemblyScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AssemblyScene.h"
#import <AVFoundation/AVFoundation.h>
#import "CommandNote.h"
#import "Action.h"
#import "Command.h"
#import "Player.h"
#import <HueSDK_OSX/HueSDK.h>
#import "OSXAppDelegate.h"

#define MAX_HUE 65536

#define InputAndDemoKey @"inputanddemo"

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

typedef enum : uint8_t {
    NotTiming,
    GoodTiming,
    GreatTiming
} TimingGrade;

NSTimeInterval      timeElapsed;
NSTimeInterval      previousTime;
SKSpriteNode        *tempCharacter;
int                 numOfReadyRound;
BOOL                readyFlag;
NSTimeInterval      lastCommandTiming;
int                 commandNumber;
BOOL                disableInput;

PHBridgeResourcesCache *cache;
NSArray *lights;
PHBridgeSendAPI *bridgeSendAPI;

@interface AssemblyScene()


@property (nonatomic, strong) NSArray               *players;

@property (nonatomic, strong) Player                *defaultPlayer;

@property (nonatomic, strong) SKSpriteNode          *background;

// cover
@property (nonatomic, strong) SKSpriteNode          *cover;

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

@property (nonatomic) AssemblyState                 gameState;

@property (nonatomic) TimingGrade                    timing;

@end



@implementation AssemblyScene


-(void)didMoveToView:(SKView *)view {

    _background = [SKSpriteNode spriteNodeWithImageNamed:@"hill"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
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
    [_defaultPlayer.character setScale:0.7f];
    [self addChild:_defaultPlayer.character];
    
    
    
    //music player
    [self setUpMusicPlayer];

    _btReceiver = ((OSXAppDelegate *)[[NSApplication sharedApplication] delegate]).btReceiver;
    _isInputTiming = NO;
    _secPerBeat = 60.0/120.0;
    _numOfRounds = 0;
    
    _gameState = SCANNING;
    timeElapsed = 0;
    previousTime = 0;
    numOfReadyRound = 1;
    readyFlag = NO;

    
    bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
}


-(void)update:(NSTimeInterval)currentTime{
    
    if(previousTime == 0)
        previousTime = currentTime;
    
    
    
    Command* latestCommand =[self getLatestCommand];;
    
    switch (_gameState) {
        case SETUP:
            break;
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
                [self startGame];
//                gameState = GRAPHICSTEST;
                NSLog(@"go to PLAYING");
            }
            
            break;
            
        case PLAYING:
            
            
            timeElapsed += currentTime - previousTime;
//            NSLog(@"timeElapsed: %f, SecPerBeat: %f, RoundsLeft: %d", timeElapsed, _secPerBeat, _numOfRounds);
            
//            //update the command input
//            latestCommand = [self getLatestCommand];
            
            //if all the rounds are finished
            if( _numOfRounds == 0){
                timeElapsed = 0;
                previousTime = 0;
                [self assemblyEnded];
                break;
            }
            
            //when is is the turn for player to input command
            if(_isInputTiming){
                
                if( !latestCommand.input == NEUTRAL && !disableInput){
                    //if no input
                    
                    //if there is command, change characters animations
                    [_defaultPlayer.character takeCommand:latestCommand.input];
                
                    if(commandNumber>3)
                        break;
                    
                    Command *targetCommand = _targetAction.commands[commandNumber];
                    CommandNote *targetNote = _commandNotes[commandNumber];
                    
                    if( targetCommand.input == latestCommand.input){
                        
                        //successful input
                        if(_timing == GreatTiming){
                            [targetNote changeToGreatTiming];
                        }
                        else if(_timing == GoodTiming){
                            [targetNote changeToGoodTiming];
                        }
                    }
                    [self runAction:[self disableInput]];

                }
                break;
                
            }
            break;
            
        case ENDED:
            [self toTournament:latestCommand];
            break;
        case GRAPHICSTEST:
            break;
        default:
            break;
    }

    previousTime = currentTime;

    
}

-(void)startGame{
    _gameState = PLAYING;
    
    [self resetAssembly];
    
    //play the music once it starts
    [_musicPlayer play];
    [self runAction:[self warmUpAction] completion: ^(void){
        //start main loop
        [self runAction:[SKAction repeatActionForever:[self mainLoop]] withKey:InputAndDemoKey];
    }];

    
    
}


-(SKAction *)mainLoop{
    return [SKAction sequence:@[
                                //DEMO
                                [SKAction runBlock:
                                 ^(void){
                                     [self resetForDemoTime];
                                 }],
                                
                                //4 beats for demo
                                [self performDemo],
                                
                                //USER INPUT
                                
                                [SKAction runBlock:
                                 ^(void){
                                     [self resetForInputTime];
                                 }],
                                
                                //get input for 4 beats
                                [SKAction repeatAction:[self checkInputSequence] count:4]

                                
                                ]
            ];
}


-(SKAction *)warmUpAction{

    return [SKAction waitForDuration:_secPerBeat*4];
}

-(SKAction *)checkInputSequence{
    return [SKAction sequence:@[
                                [SKAction runBlock:^{_timing = GreatTiming;}],
                                [SKAction waitForDuration:GREAT_TIMING_DELTA],
                                [SKAction runBlock:^{_timing = GoodTiming;}],
                                [SKAction waitForDuration:GOOD_TIMING_DELTA],
                                [SKAction runBlock:^{_timing = NotTiming;commandNumber++;}],
                                [SKAction waitForDuration:_secPerBeat - GOOD_TIMING_DELTA - GREAT_TIMING_DELTA]
                                
                                ]
            ];
}


-(SKAction *)performDemo{
    
    return [SKAction sequence:@[
                                [SKAction repeatAction:[self demoSequence] count:3],
                                [SKAction playSoundFileNamed:@"Go.wav" waitForCompletion:NO],
                                [self demoSequence]
                                ]];
    
}

-(SKAction *)demoSequence{
    return [SKAction sequence:@[
                                [self changeNote],
                                [SKAction waitForDuration:_secPerBeat],
                                [SKAction runBlock:^{commandNumber++;}]
                                ]
            ];
}




-(SKAction *)changeNote{
    return [SKAction runBlock:^(void){
        CommandNote *note = _commandNotes[commandNumber];
        [note changeTo:((Command*)_targetAction.commands[commandNumber]).input];
        [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReadyNod];
    }];
}

-(void)resetForInputTime{
    _isInputTiming = YES;
    timeElapsed = 0;
    commandNumber = 0;
    _numOfRounds --;
}

-(void)resetForDemoTime{
    _isInputTiming = NO;
    timeElapsed = 0;
    commandNumber = 0;
    
    //reset the notes to all gray
    for (CommandNote* note in _commandNotes) {
        [note changeToNeutral];
    }
    
    //random the next target action
    if(!_targetAction){
        _targetAction = [[Action alloc]initWithRandomAction];
    }
    else{
        [_targetAction randomAction];
    }
    
}


-(void)resetAssembly{
    //reset the attribute
    _numOfRounds = 16;
    timeElapsed = 0;
    _isInputTiming = NO;
}

-(void)assemblyEnded{
    timeElapsed = 0;
    previousTime = 0;
    _gameState = SCANNING;
    [self doVolumeFade];
    [self removeActionForKey:InputAndDemoKey];
}

-(SKAction *)disableInput{
    return [SKAction sequence:@[
                                [SKAction runBlock:^{disableInput = YES;}],
                                [SKAction waitForDuration:0.2],
                                [SKAction runBlock:^{disableInput = NO;}]
                                ]];
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

-(void)doVolumeFade
{
    if (_musicPlayer.volume > 0.1) {
        _musicPlayer.volume = _musicPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [_musicPlayer stop];
        _musicPlayer.currentTime = 0;
        [_musicPlayer prepareToPlay];
        _musicPlayer.volume = 1.0;
    }
}

-(void)sendHueChange{
    
    cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    // And now you can get any resource you want, for example:
    lights = [cache.lights allValues];
    [((PHLight *)lights[0]).lightState setTransitionTime:0];
    // [((PHLight *)lights[0]).lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
    [((PHLight *)lights[0]).lightState setHue:[NSNumber numberWithInt:25500]];
    [((PHLight *)lights[0]).lightState setBrightness:[NSNumber numberWithInt:128]];
    [((PHLight *)lights[0]).lightState setSaturation:[NSNumber numberWithInt:254]];


    [bridgeSendAPI updateLightStateForId:((PHLight *)lights[0]).identifier withLightState:((PHLight *)lights[0]).lightState completionHandler:^(NSArray *errors) {
        if (!errors){
            // Update successful
        } else {
            // Error occurred
        }
    }];

}

-(void)toTournament:(Command *)cmd{
    
    if(cmd.input == UP){
        NSLog(@"going to battle scene");
        [_musicPlayer stop];
        BattleScene *bs = NSAppDelegate.battleScene;
        [bs transferPlayer:_defaultPlayer];
        SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:0.5];
        [self.view presentScene:bs transition:transition];
        
        
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
