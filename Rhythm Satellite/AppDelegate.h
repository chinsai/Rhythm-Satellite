//
//  AppDelegate.h
//  Rhythm Satellite
//

//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "BTCentralModule.h"
#import <HueSDK_OSX/HueSDK.h>

#define NSAppDelegate  ((AppDelegate *)[[NSApplication sharedApplication] delegate])

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SKView *skView;
// BT communication
@property (nonatomic, strong) BTCentralModule       *btCentral;
@property (nonatomic, strong) PHHueSDK              *phHueSDK;




@end
