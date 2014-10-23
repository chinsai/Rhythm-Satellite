//
//  Timeline.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Note.h"

@interface Timeline : SKSpriteNode

//all the beat sets to be played
@property (nonatomic, strong) NSMutableArray          *notes;

-(Timeline *) initWithImageNamed: (NSString *)image andHitSpotImageNamed:(NSString *)spotImage;
-(void) update: (NSTimeInterval)currentTime;
-(void)initTimeline;


@end
