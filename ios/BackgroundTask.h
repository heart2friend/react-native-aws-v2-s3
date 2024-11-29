
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNBackgroundTaskSpec.h"

@interface BackgroundTask : NSObject <NativeBackgroundTaskSpec>
#else
#import <React/RCTBridgeModule.h>

@interface BackgroundTask : NSObject <RCTBridgeModule>
#endif

@end
