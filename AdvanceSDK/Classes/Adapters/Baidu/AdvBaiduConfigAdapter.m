//
//  AdvBaiduConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvBaiduConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>

@interface AdvBaiduConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvBaiduConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    [BaiduMobAdManager setAppsid:appId];
    [BaiduMobAdManager startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        completion? completion(error) : nil;
    }];
}

+ (NSString *)sdkVersion {
    return [BaiduMobAdManager getSDKVersion];
}

@end
