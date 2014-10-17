//
//  AppDelegate.h
//  Rhythm Satellite iOS
//
//  Created by Kiron on 2014/10/10.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *sharedManager;
@property (nonatomic, strong) AVAudioPlayer * bgmPlayer;                    //bgmPlayer
@end

