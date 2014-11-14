//
//  AlarmClockModule.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/25.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum alarmStateTypes{
    ALARM_ON,
    ALARM_PLAYING,
    ALARM_OFF
} AlarmState;


@interface AlarmClockModule : NSObject

@property (nonatomic) uint8_t                           hour;
@property (nonatomic) uint8_t                           minute;
@property (nonatomic, strong) NSDate                *alarmDate;         //alarm
@property (nonatomic) AlarmState                    alarmState;     //whether the alarm is on or not

-(NSString *)getCurrentTimeInString;

@end
