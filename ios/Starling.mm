#import "Starling.h"

#import <react_native_starling/react_native_starling-Swift.h>

@interface Starling () <BluetoothDelegate>
@end

@implementation Starling
RCT_EXPORT_MODULE()

StarlingBridge *bridge;

- (instancetype)init {
    if (self = [super init]) {
        bridge = [[StarlingBridge alloc] initWithDelegate:self];
        //bridge.delegate = self;
    }
    
    NSLog(@"[OBJ-C] Starling bridge object initialized");
    return self;
}

// Needed since we have implemented a custom init
+ (BOOL)requiresMainQueueSetup {
    return NO;
}

// Execute messages on the same queue as bluetooth events are processed on
- (dispatch_queue_t)methodQueue {
    return bridge.eventQueue;
}

- (void)startAdvertising:(NSString *)serviceUUID
      characteristicUUID:(NSString *)characteristicUUID
                appleBit:(double)appleBit {
    [bridge startAdvertisingWithServiceUUID:serviceUUID characteristicUUID: characteristicUUID];
}

- (void)stopAdvertising {
    [bridge stopAdvertising];
}

- (void)broadcastRouteRequest {
    [bridge broadcastRouteRequest];
}

- (void)sendMessage:(NSString *)contactID
               body:(NSString *)body
    attachedContact:(NSString * _Nullable)attachedContact
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
    
    NSError *err;
    [bridge sendMessageWithContactID:contactID body:body attachedContact:attachedContact error:&err];
    
    if (err != nil) {
        reject(@"send-message", [err description], err);
        return;
    }
    
    resolve(NULL);
}

- (void)newGroup:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject {
    NSError *err;
    NSString *contactID = [bridge newGroupAndReturnError:&err];
    
    if (err != nil) {
        reject(@"new-group-error", [err description], err);
        return;
    }
    
    resolve(contactID);
}


- (void)joinGroup:(NSString *)groupSecret
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    NSError *err;
    NSString *newContact = [bridge joinGroupWithGroupSecret:groupSecret error:&err];
    
    if (err != nil) {
        reject(@"join-group-error", [err description], err);
        return;
    }
    
    resolve(newContact);
}

- (NSString *)groupContactID:(NSString *)groupSecret {
    NSError *err;
    NSString *contactID = [bridge groupContactIDWithGroupSecret:groupSecret error:&err];
    
    if (err != nil) {
        NSLog(@"Failed to get group contact id from secret");
        return @"";
    }
    
    return contactID;
}

- (void)startLinkSession:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
    NSError *err;
    NSURL *url = [bridge startLinkSessionAndReturnError:&err];
    
    if (err != nil) {
        reject(@"start-link-session-error", [err description], err);
        return;
    }
    
    resolve(url.absoluteString);
}

- (void)connectLinkSession:(NSString *)url
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
    NSError *err;
    NSString *contactID = [bridge connectLinkSessionWithUrl:url error:&err];
    
    if (err != nil) {
        reject(@"start-link-session-error", [err description], err);
        return;
    }
    
    resolve(contactID);
}

- (void)deleteContact:(NSString *)contactID {
    [bridge deleteContact:contactID];
}

- (void)loadPersistedState {
    [bridge loadPersistedState];
}

- (void)deletePersistedState {
    [bridge deletePersistedState];
}

- (NSArray<NSString *> *)supportedEvents {
    return [StarlingBridge supportedEvents];
}

- (void)sendEventWithName:(NSString * _Nonnull)name result:(id)result {
    [super sendEventWithName:name body: result];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeStarlingSpecJSI>(params);
}

@end
