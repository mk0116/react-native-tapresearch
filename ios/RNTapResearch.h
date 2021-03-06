#if __has_include(<React/RCTEventEmitter.h>)
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>
#else
#import "RCTEventEmitter.h"
#import "RCTBridgeModule.h"
#endif

#import <TapResearchSDK/TapResearchSDK.h>

#define PLATFORM @"react"
#define PLATFORM_VERSION @"2.0.0"

@interface RNTapResearch : RCTEventEmitter <RCTBridgeModule, TapResearchRewardDelegate, TapResearchSurveyDelegate>

@end
