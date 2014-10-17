//
//  AlarmClockScene.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/15.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "AlarmClockScene.h"
#import "AppDelegate.h"

#define DELTA_THRESHOLD 1
#define REGISTER_INTERVAL 0.1
#define GRAVITY_THRESHOLD 0.8
#define INPUT_TOLERANCE 0.1

typedef enum alarmStateTypes{
    ALARM_ON,
    ALARM_PLAYING,
    ALARM_OFF
} AlarmState;

@interface AlarmClockScene ()
@property (nonatomic, weak) CMMotionManager *mManager;                  //CoreMotion Manager
@property (nonatomic, weak) SKLabelNode *clockLabel;                     //label for the alarm
@property (nonatomic, weak) SKLabelNode *hitLabel;                     //label for the hit times
@property (nonatomic, weak) SKLabelNode *alarmLabel;                     //label for the alarm
@property (nonatomic) double preAccelerationX;                          //previous Acceleration.X Value
@property (nonatomic) CFTimeInterval stopRegisterTime;                  //time to avoid unwanted input
@property (nonatomic) CFTimeInterval previousTime;                       //for recording the time of previous time
@property (nonatomic) BOOL canRegister;                                 //determine whether a new motion can be register
@property (nonatomic) NSDate *alarm;                                     //alarm
@property (nonatomic) AlarmState alarmState;                             //whether the alarm is on or not
@property (nonatomic) CFTimeInterval beatTimer;                         //timer for determining beat time
@property (nonatomic) double bpm;                                          //bpm of the beat to be followed
@property (nonatomic) int numberOfHits;                                 //number of hits to the beat
@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) CGPoint prevLocation;
@property (nonatomic) CGPoint newLocation;
@end

@implementation AlarmClockScene





-(void)didMoveToView:(SKView *)view {
    
    //Set up motion sensor update interval
    NSTimeInterval updateInterval = 0.01;
    _mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    if ([_mManager isDeviceMotionAvailable] == YES) {
        [_mManager setDeviceMotionUpdateInterval:updateInterval];
        [_mManager startDeviceMotionUpdates];
    }
    
    //set 0 for previous value
    _preAccelerationX = 0;
    _stopRegisterTime = 0;
    _canRegister = YES;
    _hour = 7;
    _minute = 15;
    
    
    //CLOCK
    _clockLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _clockLabel.text = [self getCurrentTimeInString];
    _clockLabel.fontSize = 24;
    _clockLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-30);
    [self addChild:_clockLabel];
    
    //ALARM
    _alarmLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _alarmLabel.text = [NSString stringWithFormat:@"%02d:%02d", _hour, _minute ];
    _alarmLabel.fontSize = 140;
    _alarmLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+250);
    [self addChild:_alarmLabel];
    
    //HIT COUNT
    _hitLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _hitLabel.text = @"0";
    _hitLabel.fontSize = 70;
    _hitLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_hitLabel];
    
//    _alarm = [[NSDate alloc] initWithTimeIntervalSinceNow: 5];
    _alarmState = ALARM_ON;
    _bpm = 120;
    _beatTimer = 0;
    _numberOfHits = 0;
    [self updateAlarm];
    
}





-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        _prevLocation.y = location.y;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
    
        CGPoint location = [touch locationInNode:self];
        int difference = location.y - _prevLocation.y;
        int steps = difference / 60;
        if( abs(steps) > 0 ){
            _prevLocation.y = location.y;
        }
        NSLog(@"steps %d", steps);
        if (location.x > CGRectGetMidX(self.frame)) {
            
            _minute += steps;
            _minute = _minute % 60;
            if (_minute < 0) {
                _minute += 60;
            }
        }
        else{
            _hour += steps;
            _hour = _hour % 24;
            if (_hour < 0) {
                _hour += 24;
            }
        }
    
    
    }
    [self updateAlarm];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)update:(CFTimeInterval)currentTime {
   
    /* Called before each frame is rendered */
    CFTimeInterval deltaTime = currentTime - _previousTime;
    
    //update Accelerometer Values
    double newAccelerationX = _mManager.deviceMotion.userAcceleration.x;
    double deltaX = newAccelerationX - _preAccelerationX;
    
    double gravityX = _mManager.deviceMotion.gravity.x;
    double gravityY = _mManager.deviceMotion.gravity.y;
    double gravityZ = _mManager.deviceMotion.gravity.z;
    
    
    _clockLabel.text = [self getCurrentTimeInString];
    NSDate *now = [NSDate date];
    if(_alarmState == ALARM_ON){
        if ([_alarm timeIntervalSinceDate:now] <= 0 ) {
            NSLog(@"Alarm!!!!!!");
            [self playBGM];
            _alarmState = ALARM_PLAYING;
        }
    }
    else if(_alarmState == ALARM_PLAYING){
        
        double beatTiming = 60/_bpm;
        
//        NSLog(@"Beat timer: %f", _beatTimer);
        
        if(_numberOfHits == 8){
            _beatTimer = 0;
            _numberOfHits = 0;
            _alarmState = ALARM_ON;
            [self stopBGM];
            [self updateAlarm];
            return;
        }
        else if( _numberOfHits >= 1){
            if(_beatTimer <= beatTiming + INPUT_TOLERANCE){
                _beatTimer += deltaTime;
            }
            else{
                _beatTimer = 0;
                _numberOfHits = 0;
//                NSLog(@"reset");
            }
        }
        
        //check if new input is allowed
        if(!_canRegister){
            if (_stopRegisterTime > REGISTER_INTERVAL){
                _stopRegisterTime = 0;
                _canRegister = YES;
            }
            else{
                _stopRegisterTime += deltaTime;
            }
        }
        else{
            
            //if the change of acceleration is larger than the threshold and the motion registered flag is not up
            //regist a new motion
            if ( deltaX > DELTA_THRESHOLD){
    //            NSLog(@"Shake");
                //stop registering unwanted commandes
                if (gravityY < -GRAVITY_THRESHOLD) {
                    NSLog(@"UP");
                }
                else if (gravityX < -GRAVITY_THRESHOLD){
                    NSLog(@"DOWN");
                }
                else if (gravityZ > GRAVITY_THRESHOLD){
                    NSLog(@"RIGHT");
                }
                else if (gravityZ < -GRAVITY_THRESHOLD){
                    NSLog(@"LEFT");
                }
                
                //start timing for rhythm input
                if (_numberOfHits == 0){
                    _numberOfHits++;
//                    NSLog(@"HIT at %f with the number of hits: %d", _beatTimer, _numberOfHits);
                    
                }
                //if there is continueous rhythmic inputs, check timing
                else {
                    if (_beatTimer >= beatTiming - INPUT_TOLERANCE && _beatTimer <= beatTiming + INPUT_TOLERANCE) {
                        _numberOfHits++;
//                        NSLog(@"HIT at %f with the number of hits: %d", _beatTimer, _numberOfHits);
                        _beatTimer = 0;
                    }
                    else {
                        _numberOfHits = 0;
                        _beatTimer = 0;
//                        NSLog(@"discontinued");
                    }
                }
                
                _canRegister = NO;
            }
        }
    }
    _preAccelerationX = newAccelerationX;
    _previousTime = currentTime;
    
    _hitLabel.text = [NSString stringWithFormat:@"%d",_numberOfHits];
    _alarmLabel.text = [NSString stringWithFormat:@"%02d:%02d", _hour, _minute ];
    
}

-(void)playBGM{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.bgmPlayer play];
}
-(void)stopBGM{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.bgmPlayer stop];
    appDelegate.bgmPlayer.currentTime = 0;
}

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
}


-(void)willMoveFromView:(SKView *)view{
    if ([_mManager isAccelerometerActive] == YES) {
        [_mManager stopDeviceMotionUpdates];
    }
}

@end