#import <React/RCTEventEmitter.h>


#ifdef RCT_NEW_ARCH_ENABLED

#import "RNStarlingSpec.h"
@interface Starling : RCTEventEmitter <NativeStarlingSpec>


#else

#import <React/RCTBridgeModule.h>
@interface Starling : RCTEventEmitter <RCTBridgeModule>

#endif

@end
