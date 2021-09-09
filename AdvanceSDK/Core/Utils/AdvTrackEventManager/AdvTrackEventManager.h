//
//  AdvTrackEventManager.h
//  Pods
//
//  Created by MS on 2021/9/8.
//

#import <Foundation/Foundation.h>
#import "AdvTrackEventDelegate.h"
NS_ASSUME_NONNULL_BEGIN
extern NSString * const AdvAnalyticsMethodCall;
extern NSString * const AdvAnalyticsUIControl;
extern NSString * const AdvAnalyticsClass;
extern NSString * const AdvAnalyticsSelector;
extern NSString * const AdvAnalyticsDetails;
extern NSString * const AdvAnalyticsParameters;
extern NSString * const AdvAnalyticsShouldExecute;
extern NSString * const AdvAnalyticsEvent;

@interface AdvTrackEventManager : NSObject
@property (nonatomic, assign) id<AdvTrackEventDelegate> delegate;

+ (instancetype)defaultManager;
- (void)configure:(NSDictionary *)configurationDictionary delegate:(id<AdvTrackEventDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
