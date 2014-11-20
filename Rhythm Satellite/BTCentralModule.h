//
//  BTModule.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTCentralModule : NSObject

@property (strong, nonatomic) NSMutableData             *receivedData;
@property (nonatomic) BOOL                              hasConnectedPeripheral;

-(void)cleanup;
-(void)scan;
-(void)stopScan;
-(long)getRSSi;
@end
