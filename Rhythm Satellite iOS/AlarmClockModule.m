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
        _alarmState = alarmOff;
        _hour = [[AlarmClockModule getCurrentHourInString] intValue];
        _minute = [[AlarmClockModule getCurrentMinuteInString] intValue];
        _alarmState = alarmOff;
        iOSAppDelegate *appDelegate = (iOSAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"RS1" withExtension:@".m4a"];
        appDelegate.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        appDelegate.bgmPlayer.numberOfLoops = -1;
        [appDelegate.bgmPlayer prepareToPlay];
        _musicPlayer = appDelegate.bgmPlayer;
        [_musicPlayer prepareToPlay];
    }
    return self;
}


+ (NSString *)getCurrentTimeInString{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:now];
}

+ (NSString *)getCurrentHourInString{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH"];
    return [dateFormatter stringFromDate:now];
}
+ (NSString *)getCurrentMinuteInString{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm"];
    return [dateFormatter stringFromDate:now];
}

-(void)setAlarmAtHour: (uint8_t)hour atMinute: (uint8_t)minute{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: now];
    [components setHour: hour];
    [components setMinute: minute];
    [components setSecond:0];
    
    _hour = hour;
    _minute = minute;
    
    _alarmDate = [gregorian dateFromComponents: components];
    if ([_alarmDate timeIntervalSinceNow] <= 0 ) {
        NSDateComponents *dc = [[NSDateComponents alloc] init];
        [dc setDay:1];
        _alarmDate = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:_alarmDate options:0];
    }
    
    if(_alarmState == alarmOn){
        [self scheduleAlarmForDate:_alarmDate];
    }
}

-(void)setAlarm{
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
    
    if(_alarmState == alarmOn){
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

-(void)playAlarm{
    [_musicPlayer play];
    _alarmState = alarmPlaying;
}
-(void)stopAlarm{
    [self doVolumeFade];
    _alarmState = alarmOff;
}

-(void)switchOnAlarm{
    _alarmState = alarmOn;
    [self setAlarm];
}
-(void)switchOffAlarm{
    _alarmState = alarmOff;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)doVolumeFade
{
    if (_musicPlayer.volume > 0.1) {
        _musicPlayer.volume = _musicPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [_musicPlayer stop];
        _musicPlayer.currentTime = 0;
        [_musicPlayer prepareToPlay];
        _musicPlayer.volume = 1.0;
    }
}

@end
