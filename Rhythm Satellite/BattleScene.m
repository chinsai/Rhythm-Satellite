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
#import "RSDialogBox.h"

#import "OSXAppDelegate.h"

#define GoSoundKey @"gosound"
#define InputAndAnimationKey @"inputandanimation"
#define FADEIN @"FADEIN"
#define FADEOUT @"FADEOUT"


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

long RSSIValue;
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

@property (nonatomic) RSDialogBox                   *dialogBox;

@property (nonatomic) SKSpriteNode                  *cover;
@end



@implementation BattleScene

-(void)didMoveToView:(SKView *)view {
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"hill_zoomed"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
    _inputCommands = [[NSMutableArray alloc]init];
    
    //music player
    [self setUpMusicPlayer];
    
    //mainplayer
    if (!_defaultPlayer) {
        _defaultPlayer = [[Player alloc]initWithPlayerName:@"Player1"];
        _defaultPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:30 withDef:15 withMoney:1000];
        
        [_defaultPlayer.character fireAnimationForState:NoriAnimationStateReady];
        SKCropNode *crop = [SKCropNode node];
        crop.maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.size.width, _defaultPlayer.character.size.height)];
        crop.position = CGPointMake(CGRectGetMidX(self.frame)-300, CGRectGetMidY(self.frame)-40);
        [crop addChild:_defaultPlayer.character];
        _defaultPlayer.character.position = CGPointMake(0.0, -_defaultPlayer.character.size.height);
        crop.zPosition = 5;
        [self addChild:crop];

    }
    
    //opponent
    _opponentPlayer = [[Player alloc]initWithPlayerName:@"No-AI"];
    _opponentPlayer.character = [[Character alloc]initWithLevel:1 withExp:200 withHp:100 withMaxHp:100 withAtt:20 withDef:15 withMoney:1000];
    _opponentPlayer.character.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame)-40);
    [_opponentPlayer.character fireAnimationForState:NoriAnimationStateReady];
    [self addChild:_opponentPlayer.character];

    _hud = [[BattleHUD alloc]initWithScene:self];
    [_hud setLeftName:_defaultPlayer.playerName];
    [_hud setRightName:_opponentPlayer.playerName];
    
    _cover = [SKSpriteNode spriteNodeWithImageNamed:@"startScreen"];
    _cover.zPosition = 1000;
    _cover.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_cover];
    
    
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
            if(_btReceiver.hasConnectedPeripheral && ![_cover hasActions]){
                [self setGameState:READY];
                
            }
            break;
        case SEARCHING:
            break;
        case WAITING:
            break;
        case READY:
            
//            NSLog(@"RSSI %ld", [_btReceiver getRSSi]);
//            RSSIValue = [_btReceiver getRSSi]; 3 
            //update the command input to look for a TAP command
            if (latestCommand.input == START) {
                NSLog(@"start");
                [self startBattle];
                [_defaultPlayer.character riseToPositionY:0.0 ForDuration:0.2];
                break;
            }
            if (latestCommand.input == TAP){
                [_btReceiver cleanup];
                [self setGameState:SCANNING];

                break;
            }
            if( RSSIValue < -44){
                NSLog(@"RSSI %ld", RSSIValue);
                [_btReceiver cleanup];
                [self setGameState:SCANNING];
                break;
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
            if (latestCommand.input == UP){
                [_dialogBox removeFromParent];
                [self startBattle];
            }else if (latestCommand.input == DOWN) {
                [_dialogBox removeFromParent];
                [_defaultPlayer.character dropToPositionY:-_defaultPlayer.character.size.height ForDuration:0.2];
                [_btReceiver cleanup];
                [self resetScreen];
                [self setGameState:SCANNING];
            }
            break;
        case GRAPHICSTEST:
            [self startBattle];
            break;
        default:
            break;
    }

    
    
}

-(void)startBattle{
    [self setGameState:PLAYING];

    [self resetBattle];

    //play the music once it starts
    [_musicPlayer play];
    
    //Loop for GO signal
    [self runAction:[SKAction repeatActionForever:[self soundEffectGoAction]] withKey:GoSoundKey];
    
    
    //startoff with Warmup Beats
    [self runAction:
     
         [SKAction sequence:@[
                        [SKAction waitForDuration:_secPerBeat*8-GOOD_TIMING_DELTA],
                        [SKAction runBlock: ^(void)
                            {
                                _timing = GoodTiming;
                                _isInputTiming = YES;
                            }
                         ],
                        [SKAction waitForDuration:GOOD_TIMING_DELTA],
                        
                        ]
          ] completion:^{
             
             [self runAction:[SKAction repeatActionForever:[self mainLoop]] withKey:InputAndAnimationKey];
         }
     
     ];

    
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
    [_defaultPlayer.character runCharacterAction];
    [_opponentPlayer.character runCharacterAction];
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
    _numOfRounds = 2;
    _isInputTiming = YES;
    [_defaultPlayer.character resetAttributes];
    [_opponentPlayer.character resetAttributes];
    [_hud resetAll];
    [_hud setRound:_numOfRounds];
}

-(void) battleEnded{
    if(_defaultPlayer.character.hp > _opponentPlayer.character.hp){
        _dialogBox = [RSDialogBox initBooleanDialogBoxWithTitle:@"You WIN! Try again?"];
    }
    else{
        _dialogBox = [RSDialogBox initBooleanDialogBoxWithTitle:@"You LOSE! Try again?"];
    }
    _dialogBox.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) );
    _dialogBox.zPosition = 100.0;
    [self addChild:_dialogBox];
    [self setGameState:ENDED];
    [self doVolumeFade];
    [self removeActionForKey:GoSoundKey];
    [self removeActionForKey:InputAndAnimationKey];
    [_hud setRound:_numOfRounds];
}

-(void)resetScreen{
    [_hud resetAll];
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
        if (_gameState==ENDED) {
            [_musicPlayer stop];
            _musicPlayer.currentTime = 0;
            [_musicPlayer prepareToPlay];
            _musicPlayer.volume = 1.0;
            return;
        }
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

-(void) fadeOutCover{
    [_cover runAction:[SKAction fadeAlphaTo:0.0 duration:0.5] withKey:FADEOUT];
}

-(void) fadeInCover{
    [_cover runAction:[SKAction fadeAlphaTo:1.0 duration:0.5] withKey:FADEIN];
}

-(void)setGameState:(BattleState)gameState{
    
    //leaving states
    switch (_gameState) {
        case SCANNING:
            [self fadeOutCover];
            break;
        case READY:
            break;
        case PLAYING:
            break;
        case ENDED:
            break;
        case GRAPHICSTEST:
            break;
        default:
            break;
    }
    
    //new states
    switch (gameState) {
        case SCANNING:
            [self fadeInCover];
            break;
        case PLAYING:
            break;
        case ENDED:
            break;
        case GRAPHICSTEST:
            break;
        default:
            break;
    }
    
    _gameState = gameState;
}
@end