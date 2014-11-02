//
//  Timeline.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Note.h"
#import "Command.h"


typedef enum timingRanking{
    NO_GRADE,
    BAD,
    GOOD,
    GREAT
} TimingType;

@interface Timeline : SKSpriteNode

//all the beat sets to be played
@property (nonatomic, strong) NSMutableArray          *notes;

-(Timeline *) initWithImageNamed: (NSString *)image andHitSpotImageNamed:(NSString *)spotImage;
//-(Timeline *) initWitHitSpotImageNamed:(NSString *)spotImage;
-(void) update: (NSTimeInterval)currentTime;
-(void)initTimeline;
-(TimingType) checkInput:(Command *)command;

@end
