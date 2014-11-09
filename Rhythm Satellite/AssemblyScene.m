//
//  AssemblyScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AssemblyScene.h"
#import <AVFoundation/AVFoundation.h>
#import "Timeline.h"
#import "BTCentralModule.h"
#import "BTPeripheralModule.h"
#import "Note.h"
#import "Action.h"
#import "Command.h"


typedef enum gameStateType{
    SCANNING,
    SEARCHING,
    WAITING,
    READY,
    PLAYING,
    ENDED,
    GRAPHICSTEST
} GameState;


NSTimeInterval      timeElapsed;
NSTimeInterval      previousTime;
GameState           gameState;
SKSpriteNode        *tempCharacter;
BOOL                inputFailed;


@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// array of character stage
@property (nonatomic, strong) NSMutableArray               *characters;

// background
@property (nonatomic, strong) SKSpriteNode          *background;

// cover
@property (nonatomic, strong) SKSpriteNode          *cover;

// timing rank label
@property (nonatomic, strong) SKLabelNode          *greatLabel;

@property (nonatomic, strong) NSMutableArray          *inputCommands;

// timelines
//@property (nonatomic, strong) NSMutableArray        *timelines;

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
    
//    Timeline* lefttimeline = [[Timeline alloc]initWithImageNamed:@"invisibletimeline" andHitSpotImageNamed:@"hitspot"];
//    lefttimeline.position = CGPointMake(CGRectGetMidX(self.frame)-103, CGRectGetMaxY(self.frame) - lefttimeline.size.height/2);
//    [self addChild:lefttimeline];
//    Timeline* righttimeline = [[Timeline alloc]initWithImageNamed:@"invisibletimeline" andHitSpotImageNamed:@"hitspot"];
//    righttimeline.position = CGPointMake(CGRectGetMidX(self.frame)+103, CGRectGetMaxY(self.frame) - righttimeline.size.height/2);
//    [self addChild:righttimeline];
//    Timeline* centertimeline = [[Timeline alloc]initWithImageNamed:@"invisibletimeline" andHitSpotImageNamed:@"hitspot"];
//    centertimeline.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - centertimeline.size.height/2+55);
//    [self addChild:centertimeline];
    
//    _timelines = [[NSMutableArray alloc]init];
//    [_timelines addObject:centertimeline];
//    [_timelines addObject:lefttimeline];
//    [_timelines addObject:righttimeline];

    _greatLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _greatLabel.text = @"SCORE";
    _greatLabel.fontSize = 24;
    _greatLabel.position = CGPointMake(140, 500);
    [self addChild:_greatLabel];

    
    tempCharacter = [SKSpriteNode spriteNodeWithImageNamed:@"nori_nod_0001"];
    tempCharacter.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100);
    [self addChild:tempCharacter];
    
//    _inputCommands = [[NSMutableArray alloc]init];
    
    
    //music player
    [self setUpMusicPlayer];

    _btReceiver = [[BTCentralModule alloc] init];
    _isInputTiming = NO;
    _secPerBeat = 60.0/120.0;
    _numOfRounds = 20;
    
    gameState = PLAYING;
    timeElapsed = 0;
    previousTime = 0;
    inputFailed = NO;
    

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
            if (latestCommand.input == COMMAND_TAP) {
                [self startGame];
                NSLog(@"go to PLAYING");
            }
            break;
            
        case PLAYING:
            
            
            timeElapsed += currentTime - previousTime;
//            NSLog(@"timeElapsed: %f, SecPerBeat: %f, RoundsLeft: %d", timeElapsed, _secPerBeat, _numOfRounds);
            
            //update the command input
            latestCommand = [self getLatestCommand];
            
            
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
                
                //if no wrong input so far
                if (!inputFailed) {
                    
                    int commandNumber = timeElapsed/_secPerBeat;
                    float inputTimingError = timeElapsed - commandNumber*_secPerBeat;
                    if ( inputTimingError < 0){
                        inputTimingError = -inputTimingError;
                    }
                    Command *targetCommand = _targetAction.commands[commandNumber];
                    
                    if( latestCommand.input == COMMAND_IDLE ){
                        //if no input
                        
                        
                        if ( timeElapsed > commandNumber*_secPerBeat + GOOD_TIMING_DELTA) {
                            //failed to input on time
                            
                            //clear the input commands
//                            [_inputCommands removeAllObjects];
                            
                            //turn to inputFail
                            inputFailed = YES;
                            
                        }

                        
                    }
                    
                    else if( targetCommand.input == latestCommand.input && inputTimingError <= GOOD_TIMING_DELTA){
                        
                        //successful input
//                        [_inputCommands addObject:latestCommand];
                        
                    }
                    else{
                        
                    }
                    
                }
                
                //when finish one round of 4 beats
                if(timeElapsed >= _secPerBeat*4){
                    timeElapsed = 0;
                    _isInputTiming = NO;
                    inputFailed = NO;
                    _greatLabel.text = @"CANT INPUT NOW";
                    _numOfRounds --;
                }
                
            }
            
             //when it is not the time for player commands
            else {
                
                if(timeElapsed >= _secPerBeat*4){
                    timeElapsed = 0;
                    _isInputTiming = YES;
                    _targetAction = [[Action alloc]initWithAction:CHARGE];
                    _greatLabel.text = @"INPUT NOW";
                }
                
                
            }
            
            
            //when the game is finished
//            if (!_musicPlayer.isPlaying) {
//                timeElapsed = 0;
//                [_btReceiver cleanup];
//                [_btReceiver scan];
//                gameState = SCANNING;
//                break;
//            }
            
           
            
            //first check input timing
//            TimingType quality = [self checkTiming:latestCommand];
            
//            [self scoreWithTiming:quality];
            
//            //update the time line
//            for (Timeline* tl in _timelines){
//                [tl update:timeElapsed];
//            }
            break;
            
        case ENDED:
            break;
        case GRAPHICSTEST:
            
//            if (timeElapsed == 0){
//                [self startGame];
//            }
//            
//            if (!_musicPlayer.isPlaying) {
//                timeElapsed = 0;
//                gameState = ENDED;
//                break;
//            }
//            
//            timeElapsed += currentTime - previousTime;
//            
//            
////            for (Timeline* tl in _timelines){
////                [tl update:timeElapsed];
////            }
            break;
        default:
            break;
    }

    previousTime = currentTime;

    
}

-(TimingType)checkTiming:(Command *)command{
    
//    if(command){
//        
//        int timelineNum = (int)command.input-1;
//        
//        if (timelineNum >2  || timelineNum < 0)
//            return NO_GRADE;
//        
//        TimingType rank = [_timelines[timelineNum] checkInput:command];
//        
//        if (rank == GREAT) {
//            _greatLabel.text = @"GREAT";
//            return GREAT;
//        }
//        else if(rank == GOOD){
//            _greatLabel.text = @"GOOD";
//            return GOOD;
//        }
//        else if(rank == BAD){
//            _greatLabel.text = @"BAD";
//            return BAD;
//        }
//        else{
//            _greatLabel.text = @"BAD";
//        }
//        
//    }
    
    
    return NO_GRADE;
}

-(void)startGame{
    gameState = PLAYING;
    
    //todo
    //get ready for gameplay
    [self setupTimeline];
    
    //play the music once it starts
    [_musicPlayer play];
    
}

-(void)scoreWithTiming:(TimingType)quality{
    ;
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

-(void)setupTimeline{
//    for (int i = 1; i<=64; i++) {
//        NoteType direction = (NoteType)arc4random_uniform(3)+1;
//        Timeline* tl = (Timeline*)_timelines[direction-1];
//        [tl.notes addObject:[[ Note alloc ] initWithDirection: direction atTime: i]];
//    }
//    //put the notes in place
//    [_timelines[0] initTimeline];
//    [_timelines[1] initTimeline];
//    [_timelines[2] initTimeline];
}

+(Action *)getRandomAction{
    ActionType t = (ActionType)arc4random_uniform(3)+1;
    Action *a = [[Action alloc]initWithAction:t];
    return a;
}
@end
