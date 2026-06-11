//
//  AdvXXCustomConfigAdapter.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/3.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomConfigAdapter.h"
#import <AdvanceSDK/AdvanceCommonConfigAdapter.h>
#import <BUAdSDK/BUAdSDK.h>

@interface AdvXXCustomConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvXXCustomConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *))completion {
    BUAdSDKConfiguration *config = [BUAdSDKConfiguration configuration];
    config.appID = appId;
    [BUAdSDKManager startWithAsyncCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        completion? completion(error) : nil;
    }];
}

+ (NSString *)sdkVersion {
    return [BUAdSDKManager SDKVersion];
}

@end
