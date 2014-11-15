//
//  Player.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/11/14.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Character.h"

@interface Player : NSObject



// NAME
@property (nonatomic, strong) NSString              *playerName;

@property (nonatomic, strong) Character             *character;

@property (nonatomic) uint8_t                       wakeupHour;
@property (nonatomic) uint8_t                       wakeupMinutes;


-(id)initWithPlayerName: (NSString *) name;

@end
