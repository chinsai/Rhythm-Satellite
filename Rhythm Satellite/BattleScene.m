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
#import "BattleHUD.h"

#import "OSXAppDelegate.h"

#define errorTolerance 0.1
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
    NotTiming,
    GoodTiming,
    PerfectTiming
} TimingGrade;


typedef enum : uint8_t {
    FreePlayBattle,
    TournamentBattle
}   GameMode;


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

@property (nonatomic) BattleHUD                     *hud;

@property (nonatomic) TimingGrade                    timing;

@end



@implementation BattleScene

-(void)didMoveToView:(SKView *)view {
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"hill_zoomed"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
    _inputCommands = [[NSMutableArray alloc]init];
    
    //music player
    [self setUpMusicPlayer];
    if (!_defaultPlayer) {
        _defaultPlayer = [[Player alloc]initWithPlayerName:@"Kiron"];
        _defaultPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:40 withDef:15 withMoney:1000];
        _defaultPlayer.character.position = CGPointMake(CGRectGetMidX(self.frame)-300, CGRectGetMidY(self.frame)-40);
        [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReady];
        [self addChild:_defaultPlayer.character];

    }
    
    _opponentPlayer = [[Player alloc]initWithPlayerName:@"OIKOS"];
    _opponentPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:20 withDef:15 withMoney:1000];
    _opponentPlayer.character.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame)-40);
    [_opponentPlayer.character fireAnimationForState:NoriAnimationStateReady];
    [self addChild:_opponentPlayer.character];

    _hud = [[BattleHUD alloc]initWithScene:self];
    [_hud setLeftName:_defaultPlayer.playerName];
    [_hud setRightName:_opponentPlayer.playerName];
    
    
    _btReceiver = NSAppDelegate.btReceiver;
    _secPerBeat = 60.0/120.0;
    _gameState = SCANNING;
    _numOfRounds = 0;
    [_hud setRound:_numOfRounds];
}

-(void)update:(NSTimeInterval)currentTime{
    
    //update the command input
    Command* latestCommand = [self getLatestCommand];
    
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

            //if all the rounds are finished
            if( _numOfRounds == 0 || _defaultPlayer.character.hp == 0 || _opponentPlayer.character.hp == 0){
                [self battleEnded];
                break;
            }
            
            //when is is the turn for player to input command
            if(_isInputTiming){//
                
                //CHECK INPUT
                if( latestCommand.input != NEUTRAL ){
                    //show animation of input
                    [_defaultPlayer.character takeCommand:latestCommand.input];
                    
//                    if( inputTimingError <= errorTolerance){
                    if( _timing == GoodTiming ){
                        NSLog(@"successful input");
                        [_inputCommands addObject:latestCommand];
//                        [_defaultPlayer.character voiceForCommand:latestCommand.input];
                        
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
                //animation
                //round result
                
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

    
    
}

-(void)startBattle{
    _gameState = PLAYING;

    [self resetBattle];
    
    //play the music once it starts
    [_musicPlayer play];
    
    //Loop for GO signal
    [self runAction:[SKAction repeatActionForever:[self soundEffectGoAction]] withKey:GoSoundKey];
    
    
    //startoff with Warmup Beats
    [self runAction:[SKAction waitForDuration:_secPerBeat*8] completion: ^(void){
        //start main loop
        [self runAction:[SKAction repeatActionForever:[self mainLoop]] withKey:InputAndAnimationKey];
    }];
}

-(SKAction *)mainLoop{
    return [SKAction sequence:@[
                                
                                //reset blocks
                                [SKAction runBlock:
                                 ^(void){
                                    [_opponentPlayer.character generateAction];
                                     
                                     //animate the Opponent player (CPU)
                                     [_opponentPlayer.character animateMovesWithSecondsPerBeat:_secPerBeat];
                                     
                                     //get input for 4 beats
                                     [self runAction:[SKAction repeatAction:[self checkInputSequence] count:4]];
                                     
                                     
                                 }],
                                
                                //4 beats for input
                                [SKAction waitForDuration:_secPerBeat*4],
                                
                                [SKAction runBlock:
                                 ^(void){
                                     [self resetForAnimationTime];
                                 }],
                                
                                [self performAnimation],
                                
                                //4 beats for result, animation
                                [SKAction waitForDuration:_secPerBeat*4-GOOD_TIMING_DELTA],
                                
                                //allow earlier beat input before switching to input session
                                [SKAction runBlock:^{_timing = GoodTiming;[self resetForInputTime];}],
                                [SKAction waitForDuration:GOOD_TIMING_DELTA],
                                
                                
                                ]
            ];
}


-(SKAction *)soundEffectGoAction{
    return [SKAction sequence:@[
                         [SKAction waitForDuration:_secPerBeat*7],
                         [SKAction playSoundFileNamed:@"Go.wav" waitForCompletion:NO],
                         [SKAction waitForDuration:_secPerBeat]
                         ]
            ];
}
-(SKAction *)checkInputSequence{
    return [SKAction sequence:@[
                                
                                [SKAction waitForDuration:GOOD_TIMING_DELTA],
                                [SKAction runBlock:^{_timing = NotTiming;}],
                                [SKAction waitForDuration:_secPerBeat - GOOD_TIMING_DELTA*2],
                                [SKAction runBlock:^{_timing = GoodTiming;}],
                                [SKAction waitForDuration:GOOD_TIMING_DELTA],
                                ]
            ];
}
-(SKAction *)performAnimation{
    return [SKAction runBlock:^(void){
        NSLog(  @"Player 1 Perform Action: %@",[_defaultPlayer.character.nextAction toString] );
        NSLog(  @"Player 2 Perform Action: %@",[_opponentPlayer.character.nextAction toString] );
        
        [self processResult];
        
        
        NSLog(  @"Player 1 HP: %d Charge: %d",_defaultPlayer.character.hp, _defaultPlayer.character.chargedEnergy );
        NSLog(  @"Player 2 HP: %d Charge: %d",_opponentPlayer.character.hp, _opponentPlayer.character.chargedEnergy );
        [_hud updateHPWithLeft:(float)_defaultPlayer.character.hp/_defaultPlayer.character.maxHp
                      andRight:(float)_opponentPlayer.character.hp/_opponentPlayer.character.maxHp];
    }];
}

-(void)processResult{
    if(!_defaultPlayer.character.nextAction){
        _defaultPlayer.character.nextAction = [[Action alloc]initWithAction:NONE];
    }
    [_defaultPlayer.character updateCharge];
    [_hud updateChargeOfLeftCharacter:_defaultPlayer.character];
    [_hud updateChargeOfRightCharacter:_opponentPlayer.character];
    [_defaultPlayer.character compareResultFromCharacter:_opponentPlayer.character];
    _defaultPlayer.character.nextAction = nil;
}

-(void)resetForInputTime{
    _isInputTiming = YES;
    //clear out input commands
    [_inputCommands removeAllObjects];
    _numOfRounds --;
    [_hud setRound:_numOfRounds];
}

-(void)resetForAnimationTime{
    _isInputTiming = NO;
}


-(void)resetBattle{
    //reset the attribute
    _numOfRounds = 16;
    _isInputTiming = YES;
    [_defaultPlayer.character resetAttributes];
    [_opponentPlayer.character resetAttributes];
    [_hud resetAll];
    [_hud setRound:_numOfRounds];
}

-(void) battleEnded{
    _gameState = SCANNING;
    [self doVolumeFade];
    [self removeActionForKey:GoSoundKey];
    [self removeActionForKey:InputAndAnimationKey];
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

@end