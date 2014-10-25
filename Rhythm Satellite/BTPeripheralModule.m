//
//  BTPeripheralModule.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/20.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "BTPeripheralModule.h"
#import "TransferService.h"

@interface BTPeripheralModule()<CBPeripheralManagerDelegate>
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end


@implementation BTPeripheralModule


-(BTPeripheralModule *)init{
    if(!self)
        self = [super init];
    
    // Start up the CBPeripheralManager
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    _isSubscribed = NO;

    
    return self;
}


/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn){
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    //The service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
    
//    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
//    NSLog(@"advertising");
    
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    
    _isSubscribed = YES;
    
    [self.peripheralManager stopAdvertising];
    
    //    // Get the data
    //    self.dataToSend = [@"Left" dataUsingEncoding:NSUTF8StringEncoding];
    //
    //    // Reset the index
    //    self.sendDataIndex = 0;

    
    // Start sending
    //    [self sendData];
    
}

/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
    
    //restart advertising
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    _isSubscribed = NO;
}



- (void)sendData{
    [self.peripheralManager updateValue:self.dataToSend forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
    NSLog(@"data sent");
}




/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    //    [self sendData];
}

-(void)toggleAdvertising{
    
    if (!self.peripheralManager.isAdvertising) {
        
        // All we advertise is our service's UUID
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
        NSLog(@"advertising");
    }
    
    else {
        [self.peripheralManager stopAdvertising];
        NSLog(@"stop advertising");
    }
    
}


@end
