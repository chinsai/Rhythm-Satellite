//
//  AssemblyScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AssemblyScene.h"
#import "Note.h"
#import "Command.h"

typedef enum gameStateType{
    SEARCHING,
    WAITING,
    PLAYING,
    ENDED
} GameState;


NSTimeInterval      timeElapsed;
NSTimeInterval      previousTime;
GameState           gameState;

@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// array of character stage
@property (nonatomic, strong) NSArray               *characters;

// background
@property (nonatomic, strong) SKSpriteNode          *background;

// cover
@property (nonatomic, strong) SKSpriteNode          *cover;

// timeline
@property (nonatomic, strong) Timeline              *timeline;

// music

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

    
    
    
    _btReceiver = [[BTCentralModule alloc] init];
    
    
    gameState = PLAYING;
    timeElapsed = 0;
    previousTime = 0;
    
    [self setupTimeline];
    
}


-(void)update:(NSTimeInterval)currentTime{
    
    if(previousTime == 0)
        previousTime = currentTime;
    
    timeElapsed += currentTime - previousTime;
    
    //update the command input
    Command *command = [self getLatestCommand];
    
    
    if(command){
        TimingType rank = [_timeline checkInput:command];
        if (rank == GREAT) {
            NSLog(@"GREAT");
        }
        else if(rank == GOOD){
            NSLog(@"GOOD");
        }
        else if(rank == BAD){
            NSLog(@"BAD");
        }
    }
    
    //update the time line
    [_timeline update:timeElapsed];
    
    previousTime = currentTime;

    
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


-(void)setupTimeline{
    for (int i = 1; i<=64; i++) {
        NoteType direction = (NoteType)arc4random_uniform(3)+1;
        [_timeline.notes addObject:[[ Note alloc ] initWithDirection: direction atTime: i]];
    }
    //put the notes in place
    [_timeline initTimeline];
}
@end
