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
    ENDED
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

// timeline
@property (nonatomic, strong) Timeline              *timeline;

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
    
    _timeline = [[Timeline alloc]initWithImageNamed:@"timeline" andHitSpotImageNamed:@"hitspot"];
    _timeline.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-_timeline.size.height/2-30);
    [self addChild:_timeline];

    _greatLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _greatLabel.text = @"SCORE";
    _greatLabel.fontSize = 24;
    _greatLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-30);
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
            
            if (!_musicPlayer.isPlaying) {
                timeElapsed = 0;
                [_btReceiver cleanup];
                [_btReceiver scan];
                gameState = SCANNING;
            }
            
            timeElapsed += currentTime - previousTime;
            
            //update the command input
            lastestCommand = [self getLatestCommand];
            
            //first check input timing
            TimingType quality = [self checkTiming:lastestCommand];
            
            [self scoreWithTiming:quality];
            
            //update the time line
            [_timeline update:timeElapsed];
            
            break;
            
        case ENDED:
            break;
        default:
            break;
    }

    previousTime = currentTime;

    
}

-(TimingType)checkTiming:(Command *)command{
    
    if(command){
        TimingType rank = [_timeline checkInput:command];
        if (rank == GREAT) {
//            NSLog(@"GREAT");
            _greatLabel.text = @"GREAT";
            return GREAT;
        }
        else if(rank == GOOD){
            _greatLabel.text = @"GOOD";
//            NSLog(@"GOOD");
            return GOOD;
        }
        else if(rank == BAD){
            _greatLabel.text = @"BAD";
//            NSLog(@"BAD");
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
        [_timeline.notes addObject:[[ Note alloc ] initWithDirection: direction atTime: i]];
    }
    //put the notes in place
    [_timeline initTimeline];
}
@end
