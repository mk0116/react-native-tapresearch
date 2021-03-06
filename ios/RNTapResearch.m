#import "RNTapResearch.h"
#import <objc/runtime.h>


@implementation RNTapResearch
{
  bool hasListeners;
  NSMutableDictionary *placementsCache;
}

RCT_EXPORT_MODULE();
- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

#pragma mark - Exported Methods

RCT_EXPORT_METHOD(initWithApiToken:(NSString *)apiToken)
{
  [TapResearch initWithApiToken:apiToken developmentPlatform:PLATFORM developmentPlatformVersion:PLATFORM_VERSION delegate:self];
}

RCT_EXPORT_METHOD(setUniqueUserIdentifier:(NSString *)userIdentifier)
{
  [TapResearch setUniqueUserIdentifier:userIdentifier];
}

RCT_EXPORT_METHOD(initPlacement:(NSString *)placementIdentifier callback:(RCTResponseSenderBlock) callback)
{
  if (!placementsCache) {
    placementsCache = [[NSMutableDictionary alloc] init];
  }
  [TapResearch initPlacementWithIdentifier:placementIdentifier placementBlock:^(TRPlacement *placement) {
    [placementsCache setObject:placement forKey:placement.placementIdentifier];
    NSDictionary *placementDict = [TRSerilizationHelper dictionaryWithPropertiesOfObject:placement];
    callback(@[placementDict]);
  }];
}

RCT_EXPORT_METHOD(showSurveyWall:(NSDictionary *)placementDict)
{
  if (!placementsCache) {
    NSLog(@"Init placement wasn't called there is no available placement");
    return;
  }
  NSString *placementIdentifier = [placementDict objectForKey:@"placementIdentifier"];
  TRPlacement *placement = [placementsCache objectForKey:placementIdentifier];
  if (!placement) {
    NSLog(@"Placement is missing make sure you are passing the right placement");
    return;
  }
  [placement showSurveyWallWithDelegate:self];
}

RCT_EXPORT_METHOD(setNavigationBarColor:(NSString *)hexColor)
{
  UIColor *color = [RNTapResearch colorFromHexString:hexColor];
  [TapResearch setNavigationBarColor:color];
}

RCT_EXPORT_METHOD(setNavigationBarText:(NSString *)text)
{
  [TapResearch setNavigationBarText:text];
}

RCT_EXPORT_METHOD(setNavigationBarTextColor:(NSString *)hexColor)
{
  UIColor *color = [RNTapResearch colorFromHexString:hexColor];
  [TapResearch setNavigationBarTextColor:color];
}


#pragma mark - TapResearchSurveyDelegate
- (void)tapResearchSurveyWallOpenedWithPlacement:(TRPlacement *)placement
{
  [self emitPlacement:placement eventName:@"tapResearchOnSurveyWallOpened"];
}

- (void)tapResearchSurveyWallDismissedWithPlacement:(TRPlacement *)placement
{
  [self emitPlacement:placement eventName:@"tapResearchOnSurveyWallDismissed"];
}

- (void)emitPlacement:(TRPlacement *)placement eventName:(NSString *)eventName
{
  NSDictionary *placementDict = [TRSerilizationHelper dictionaryWithPropertiesOfObject:placement];
  NSLog(@"Sending event %@", eventName);
  [self sendEventWithName:eventName body:placementDict];
}

#pragma mark - TapResearchRewardsDelegate

- (void)tapResearchDidReceiveReward:(TRReward *)reward
{
  if (hasListeners) {
    NSDictionary *rewardDict = [TRSerilizationHelper dictionaryWithPropertiesOfObject:reward];
    [self sendEventWithName:@"tapResearchOnReceivedReward" body:rewardDict];
  }
}

#pragma Lifecycle

-(void)startObserving
{
  hasListeners = YES;
}

-(void)stopObserving
{
  hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[
           @"tapResearchOnSurveyWallOpened",
           @"tapResearchOnSurveyWallDismissed",
           @"tapResearchOnReceivedReward",
           ];
}

#pragma helpers


+ (UIColor *)colorFromHexString:(NSString *)hexString {
  unsigned rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1];
  [scanner scanHexInt:&rgbValue];

  return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
