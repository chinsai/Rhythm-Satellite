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
    IDLE,
    PLAYING,
    ENDED
} GameState;


NSTimeInterval      timeElapsed;
NSTimeInterval      previousTime;
GameState           gameState;

@interface AssemblyScene()

// array of character stage
@property (nonatomic, strong) NSArray               *charactertStages;

// background
@property (nonatomic, strong) SKSpriteNode          *background;

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
    
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: UP atTime: 1]];
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: UP atTime: 2]];
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: UP atTime: 3]];
    [_timeline.notes addObject:[[ Note alloc ] initWithDirection: UP atTime: 4]];
    
    [_timeline initTimeline];
    
    _btReceiver = [[BTCentralModule alloc] init];
    
    
    gameState = PLAYING;
    timeElapsed = 0;
    previousTime = 0;
    
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

@end
