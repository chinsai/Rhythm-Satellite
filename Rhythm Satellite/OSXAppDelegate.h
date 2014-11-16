//
//  AppDelegate.h
//  Rhythm Satellite
//

//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "BTCentralModule.h"
#import "BTPeripheralModule.h"
#import <HueSDK_OSX/HueSDK.h>
#import "AssemblyScene.h"
#import "BattleScene.h"

#define NSAppDelegate  ((OSXAppDelegate *)[[NSApplication sharedApplication] delegate])

@interface OSXAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SKView *skView;
// BT communication
@property (nonatomic, strong) BTCentralModule       *btReceiver;
@property (nonatomic, strong) PHHueSDK              *phHueSDK;
@property (nonatomic, strong, getter=getAssemblyScene) AssemblyScene         *assemblyScene;
@property (nonatomic, strong, getter=getBattleScene) BattleScene           *battleScene;

-(BattleScene *)getBattleScene;
-(AssemblyScene *)getAssemblyScene;


@end
