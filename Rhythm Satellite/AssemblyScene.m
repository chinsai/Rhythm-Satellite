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

//int                 numOfGreat;
//int                 numOfGood;
//int                 numOfBad;

@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// array of character stage
@property (nonatomic, strong) NSArray               *characters;

// background
@property (nonatomic, strong) SKSpriteNode          *background;

// cover
@property (nonatomic, strong) SKSpriteNode          *cover;

// timing rank label
@property (nonatomic, strong) SKLabelNode          *greatLabel;

// timelines
@property (nonatomic, strong) NSMutableArray        *timelines;

// music
@property (nonatomic, strong) AVAudioPlayer         *musicPlayer;

// BLE Central
@property (nonatomic, strong) BTCentralModule       *btReceiver;


@end



@implementation AssemblyScene


-(void)didMoveToView:(SKView *)view {

    _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
    
    Timeline* lefttimeline = [[Timeline alloc]initWithImageNamed:@"invisibletimeline" andHitSpotImageNamed:@"hitspot"];
    lefttimeline.position = CGPointMake(CGRectGetMidX(self.frame)-103, CGRectGetMaxY(self.frame) - lefttimeline.size.height/2);
    [self addChild:lefttimeline];
    Timeline* righttimeline = [[Timeline alloc]initWithImageNamed:@"invisibletimeline" andHitSpotImageNamed:@"hitspot"];
    righttimeline.position = CGPointMake(CGRectGetMidX(self.frame)+103, CGRectGetMaxY(self.frame) - righttimeline.size.height/2);
    [self addChild:righttimeline];
    Timeline* centertimeline = [[Timeline alloc]initWithImageNamed:@"invisibletimeline" andHitSpotImageNamed:@"hitspot"];
    centertimeline.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - centertimeline.size.height/2+55);
    [self addChild:centertimeline];
        
    _timelines = [[NSMutableArray alloc]init];
    [_timelines addObject:centertimeline];
    [_timelines addObject:lefttimeline];
    [_timelines addObject:righttimeline];

    _greatLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _greatLabel.text = @"SCORE";
    _greatLabel.fontSize = 24;
    _greatLabel.position = CGPointMake(140, 500);
    [self addChild:_greatLabel];

    
    //music player
    [self setUpMusicPlayer];
    
    
    
    
    _btReceiver = [[BTCentralModule alloc] init];
    gameState = SCANNING;
    timeElapsed = 0;
    previousTime = 0;

}


-(void)update:(NSTimeInterval)currentTime{
    
    if(previousTime == 0)
        previousTime = currentTime;
    
    
    
    Command* lastestCommand;
    
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
            lastestCommand = [self getLatestCommand];
            if (lastestCommand.input == COMMAND_TAP) {
                [self startGame];
                NSLog(@"go to PLAYING");
            }
            break;
        case PLAYING:
            //when the game is finished
            if (!_musicPlayer.isPlaying) {
                timeElapsed = 0;
                [_btReceiver cleanup];
                [_btReceiver scan];
                gameState = SCANNING;
                break;
            }
            
            timeElapsed += currentTime - previousTime;
            
            //update the command input
            lastestCommand = [self getLatestCommand];
            
            //first check input timing
            TimingType quality = [self checkTiming:lastestCommand];
            
            [self scoreWithTiming:quality];
            
            //update the time line
            for (Timeline* tl in _timelines){
                [tl update:timeElapsed];
            }
            break;
            
        case ENDED:
            break;
        case GRAPHICSTEST:
            if (timeElapsed == 0){
                [self startGame];
            }
            if (!_musicPlayer.isPlaying) {
                timeElapsed = 0;
                gameState = ENDED;
                break;
            }
            timeElapsed += currentTime - previousTime;
            for (Timeline* tl in _timelines){
                [tl update:timeElapsed];
            }
            break;
        default:
            break;
    }

    previousTime = currentTime;

    
}

-(TimingType)checkTiming:(Command *)command{
    
    if(command){
        
        int timelineNum = (int)command.input-1;
        
        if (timelineNum >2  || timelineNum < 0)
            return NO_GRADE;
        
        TimingType rank = [_timelines[timelineNum] checkInput:command];
        if (rank == GREAT) {
            _greatLabel.text = @"GREAT";
            return GREAT;
        }
        else if(rank == GOOD){
            _greatLabel.text = @"GOOD";
            return GOOD;
        }
        else if(rank == BAD){
            _greatLabel.text = @"BAD";
            return BAD;
        }
        else{
            _greatLabel.text = @"BAD";
        }
        
    }
    
    
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
    for (int i = 1; i<=64; i++) {
        NoteType direction = (NoteType)arc4random_uniform(3)+1;
        Timeline* tl = (Timeline*)_timelines[direction-1];
        [tl.notes addObject:[[ Note alloc ] initWithDirection: direction atTime: i]];
    }
    //put the notes in place
    [_timelines[0] initTimeline];
    [_timelines[1] initTimeline];
    [_timelines[2] initTimeline];
}
@end
