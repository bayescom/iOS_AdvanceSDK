//
//  AdvTrackEventUtil.m
//  AdvanceSDK
//
//  Created by MS on 2021/9/9.
//

#import "AdvTrackEventUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvTrackEventParameters.h"

#import "AdvAnalytics.h"
@interface AdvTrackEventUtil ()<AdvAnalyticsProvider>
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *events11;
@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, copy) NSString *mediaId;

@end

@implementation AdvTrackEventUtil

- (instancetype)initUtilWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    self = [super init];
    if (self) {
        self.adspotId = adspotId;
        self.mediaId = mediaId;
        [self initClass];
    }
    return self;
}

- (void)initClass {
    // 注册要监听的事件
//    [[AdvTrackEventManager defaultManager] configure:@{AdvAnalyticsMethodCall : self.events} delegate:self];
    [[AdvAnalytics shared] configure:@{AdvAnalyticsMethodCall: self.events11} provider:self];
}

- (void)event:(NSString *)event withParameters:(NSDictionary *)parameters {
    NSLog(@"%s  %@   %@", __func__, event, parameters);
}


- (void)trackAdvEvent:(NSString *)event withParameters:(NSDictionary *)parameters {
    

    NSLog(@"%s  %@   %@", __func__, event, parameters);
}

// 注册事件
- (void)advTrackEventActionWithCase:(AdvTrackEventCase)eventCase {
//    NSLog(@"---------<<<<<<");
    [[AdvTrackEventParameters new] advTrackEventParametersActionWithCase:eventCase];
}

- (NSArray *)events11 {
    if (!_events11) {
        _events11 = @[
            @{
                AdvAnalyticsClass : AdvTrackEventParameters.class,
                AdvAnalyticsDetails : @[
                        @{
                            AdvAnalyticsEvent: @"拉取数据统计",
                            AdvAnalyticsSelector: NSStringFromSelector(@selector(getInfoAction:)),
                            AdvAnalyticsParameters : ^NSDictionary *(AdvTrackEventParameters *instace, NSArray *params) {
//                                NSLog(@"----->  %@ %@", instace, params);
                                return @{@"拉取数据的统计":@"111111111"};
                            }
                        },
                ]
            },
            
            @{
                AdvAnalyticsClass : AdvTrackEventParameters.class,
                AdvAnalyticsDetails : @[
                        @{
                            AdvAnalyticsEvent: @"数据解析的统计",
                            AdvAnalyticsSelector: NSStringFromSelector(@selector(getDataAction:)),
                            AdvAnalyticsParameters : ^NSDictionary *(AdvTrackEventUtil *instace, NSArray *params) {
                                return @{@"数据解析的统计":@"222222222"};
                            }
                        }
                ]
            }
        ];
    }
    return _events11;
}

@end
