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
#define REGISTER_INTERVAL 0.08
#define GRAVITY_THRESHOLD 0.8


@interface AlarmClockScene ()
@property (nonatomic, weak) CMMotionManager *mManager;                  //CoreMotion Manager
@property (nonatomic, weak) SKLabelNode *clockLabel;                     //label for the alarm
@property (nonatomic) double preAccelerationX;                          //previous Acceleration.X Value
@property (nonatomic) CFTimeInterval stopRegisterTime;                  //time to avoid unwanted input
@property (nonatomic) CFTimeInterval previousTime;                       //for recording the time of previous time
@property (nonatomic) BOOL canRegister;                                 //determine whether a new motion can be register
@property (nonatomic) NSDate *alarm;                                     //alarm
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
    
    _clockLabel = [SKLabelNode labelNodeWithFontNamed:@"Damascus"];
    _clockLabel.text = [self getCurrentTimeInString];
    _clockLabel.fontSize = 140;
    _clockLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMidY(self.frame)+250);
    [self addChild:_clockLabel];
    
    
    _alarm = [[NSDate alloc] initWithTimeIntervalSinceNow: 10];
    
}

-(NSString *)getCurrentTimeInString{
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:now];
    
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)update:(CFTimeInterval)currentTime {
    
    _clockLabel.text = [self getCurrentTimeInString];
    
    if ([[NSDate date] laterDate:_alarm] ) {
        NSLog(@"Alarm!!!!!!");
    }
    
    /* Called before each frame is rendered */
    CFTimeInterval deltaTime = currentTime - _previousTime;
    //update Accelerometer Values
    double newAccelerationX = _mManager.deviceMotion.userAcceleration.x;
    double deltaX = newAccelerationX - _preAccelerationX;
    
    double gravityX = _mManager.deviceMotion.gravity.x;
    double gravityY = _mManager.deviceMotion.gravity.y;
    double gravityZ = _mManager.deviceMotion.gravity.z;
    
//    NSLog(@"x: %f, y: %f, z: %f", gravityX, gravityY, gravityZ );
    
    
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
            
            
            _canRegister = NO;
        }
        
    }
    _preAccelerationX = newAccelerationX;
    _previousTime = currentTime;
    
}

-(void)willMoveFromView:(SKView *)view{
    if ([_mManager isAccelerometerActive] == YES) {
        [_mManager stopDeviceMotionUpdates];
    }
}

@end