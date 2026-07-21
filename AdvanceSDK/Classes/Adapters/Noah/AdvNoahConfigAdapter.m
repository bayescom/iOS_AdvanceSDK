//
//  AdvNoahConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <NoahSDK/NoahSDK.h>

@interface AdvNoahConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvNoahConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    NoahSdkConfig *sdkConfig = [NoahSdkConfig new];
    sdkConfig.appKey = appId;
    sdkConfig.forbidHcGetLocationInfo = YES;
    [NASDKManager initWithSdkConfig:sdkConfig completion:^(BOOL success, NSError * _Nonnull error) {
        completion? completion(error) : nil;
    }];
}

+ (NSString *)sdkVersion {
    return [NASDKManager sdkVersion];
}

@end
