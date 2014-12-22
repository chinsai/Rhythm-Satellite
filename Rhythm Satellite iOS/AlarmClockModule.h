//
//  AlarmClockModule.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/25.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  : uint8_t{
    alarmOn,
    alarmPlaying,
    alarmOff
} AlarmState;


@interface AlarmClockModule : NSObject

@property (nonatomic) int8_t                           hour;
@property (nonatomic) int8_t                           minute;
@property (nonatomic, strong) NSDate                *alarmDate;         //alarm
@property (nonatomic) AlarmState                    alarmState;     //whether the alarm is on or not

+(NSString *)getCurrentTimeInString;
+(NSString *)getCurrentHourInString;
+(NSString *)getCurrentMinuteInString;
-(void)setAlarm;
-(void)setAlarmAtHour: (uint8_t)hour atMinute: (uint8_t)minute;
-(void)playAlarm;
-(void)stopAlarm;
-(void)switchOnAlarm;
-(void)switchOffAlarm;

@end
