//
//  AppDelegate.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/10.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "OSXAppDelegate.h"
#import "AssemblyScene.h"


@interface OSXAppDelegate()
@property (nonatomic, strong) NSAlert *noConnectionAlert;
@property (nonatomic, strong) NSAlert *noBridgeFoundAlert;
@property (nonatomic, strong) NSAlert *authenticationFailedAlert;
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;
@end


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
        
    return scene;
}

@end

@implementation OSXAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    _btReceiver = [[BTCentralModule alloc] init];
    
//    AssemblyScene *scene = [[AssemblyScene alloc] initWithSize:self.skView.bounds.size];

    
    
//    /* Set the scale mode to scale to fit the window */
    BattleScene *scene = [self getBattleScene];
//    AssemblyScene *scene = [self getAssemblyScene];
    
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    /* Sprite Kit applies additional optimizations to improve rendering performance */
    self.skView.ignoresSiblingOrder = YES;
    
//    self.skView.frameInterval = 2;
    
//    self.skView.showsFPS = YES;
//    self.skView.showsNodeCount = YES;
    
    [self setUpHue];
    
}

-(BattleScene *)getBattleScene{
    if(!_battleScene){
        _battleScene = [[BattleScene alloc] initWithSize:self.skView.bounds.size];
    }
    return _battleScene;
}
-(AssemblyScene *)getAssemblyScene{
    if(!_assemblyScene){
        _assemblyScene = [[AssemblyScene alloc] initWithSize:self.skView.bounds.size];
    }
    return _assemblyScene;
}

-(void)setUpHue{
    /* HUE setup */
    _phHueSDK = [[PHHueSDK alloc] init];
    
    // Enable logging, usefull during development for debugging
    [self.phHueSDK enableLogging:YES];
    
    // Call startUpSDK which will initialize the SDK
    [self.phHueSDK startUpSDK];
    
    // Initialize bridge searching class with UPnP search and Portal search enabled (retain this object during search)
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    
    // Start search for bridges
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        
        if(bridgesFound.count>0){
            
            NSArray *allKeys = [bridgesFound allKeys];
            NSArray *allValues = [bridgesFound allValues];
            
            [self.phHueSDK setBridgeToUseWithIpAddress:allValues[0] macAddress:allKeys[0]];
            NSLog(@"IPAddress %@", allValues[0]);
            
        }
        else{
            //            [self showNoBridgesFoundDialog];
            NSLog(@"NoBridgeFound");
        }
        
    }];
    
    // Register for notifications about pushlinking
    PHNotificationManager *phNotificationMgr = [PHNotificationManager defaultManager];
    
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationSuccess) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationFailed) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalConnection) forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalBridge) forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(buttonNotPressed:) forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    
    // Call to the Hue SDK to start the pushlinking process
    [self.phHueSDK startPushlinkAuthentication];
    NSLog(@"PUSH IT!");
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
     This notification will notify that there is no authentication against the bridge
     *****************************************************/
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    /***************************************************
     The local heartbeat is a regular timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed
     by the bridge into the Bridge Resources Cache
     *****************************************************/
    
    // Configure a resource specific heartbeat before calling enableLocalConnection
    [self.phHueSDK setLocalHeartbeatInterval:20.0f forResourceType: RESOURCES_LIGHTS];
    
    
    [self.phHueSDK enableLocalConnection];
    
    
    
    
}

#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    NSLog(@"Connection is ok!");
    // Check current connection state
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    NSLog(@"Connection is NOT ok!");
    // Check current connection state
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    NSLog(@"notAuthenticated");
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    //    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

/**
 Shows the no bridges found alert
 */
- (void)showNoBridgesFoundDialog {
    int response;
    self.noBridgeFoundAlert=[[NSAlert alloc] init];
    [self.noBridgeFoundAlert setMessageText:NSLocalizedString(@"No bridges", @"No bridge found alert title")];
    [self.noBridgeFoundAlert setInformativeText:NSLocalizedString(@"Could not find bridge", @"No bridge found alert message")];
    [self.noBridgeFoundAlert addButtonWithTitle:NSLocalizedString(@"Retry", @"No bridge found alert retry button")];
    [self.noBridgeFoundAlert addButtonWithTitle:NSLocalizedString(@"Cancel", @"No bridge found alert cancel button")];
    [self.noBridgeFoundAlert setAlertStyle:NSCriticalAlertStyle];
    
    [self.noBridgeFoundAlert beginSheetModalForWindow:self.window
                                        modalDelegate:self
                                       didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                          contextInfo:&response];
}

@end