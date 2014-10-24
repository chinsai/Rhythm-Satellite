//
//  BTPeripheralModule.h
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTPeripheralModule : NSObject

- (void)sendData;

- (void)toggleAdvertising;

@property (nonatomic, readwrite) BOOL                   isSubscribed;
@property (strong, nonatomic) NSData                    *dataToSend;

@end
