//
//  AlarmClockModule.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/25.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AlarmClockModule.h"
#import "iOSAppDelegate.h"

@implementation AlarmClockModule

- (id)init{
    if(self = [super init]){
        ;
    }
    return self;
}


+ (NSString *)getCurrentTimeInString{
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
    
    _alarmDate = [gregorian dateFromComponents: components];
    if ([_alarmDate timeIntervalSinceNow] <= 0 ) {
        NSDateComponents *dc = [[NSDateComponents alloc] init];
        [dc setDay:1];
        _alarmDate = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:_alarmDate options:0];
    }
    
    if(_alarmState == ALARM_ON){
        [self scheduleAlarmForDate:_alarmDate];
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
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    if (notification)
    {
        notification.fireDate = theDate;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = 0;
        notification.soundName = @"simplebeat.caf";
        notification.alertBody = @"It's almost time for NoriNori Assembly!";
        notification.alertAction = NSLocalizedString(@"Start Preparing", nil);
        [app scheduleLocalNotification:notification];
    }
}

@end
