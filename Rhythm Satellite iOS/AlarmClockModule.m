//
//  AlarmClockModule.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/25.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AlarmClockModule.h"

@implementation AlarmClockModule

-(NSString *)getCurrentTimeInString{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:now];
}

-(void)updateAlarm{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: now];
    [components setHour: _hour];
    [components setMinute: _minute];
    [components setSecond:0];
    
    _alarm = [gregorian dateFromComponents: components];
    if ([_alarm timeIntervalSinceNow] <= 0 ) {
        NSDateComponents *dc = [[NSDateComponents alloc] init];
        [dc setDay:1];
        _alarm = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:_alarm options:0];
    }
    
    if(_alarmState == ALARM_ON){
        [self scheduleAlarmForDate:_alarm];
    }
}


- (void)scheduleAlarmForDate:(NSDate*)theDate
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    // Create a new notification.
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        alarm.fireDate = theDate;
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.soundName = @"simplebeat.caf";
        alarm.alertBody = @"It's almost time for NoriNori Assembly!";
        alarm.alertAction = NSLocalizedString(@"Start Preparing", nil);
        [app scheduleLocalNotification:alarm];
    }
}

@end
