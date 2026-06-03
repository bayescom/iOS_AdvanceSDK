//
//  AdvCSJConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvCSJConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <BUAdSDK/BUAdSDK.h>

@interface AdvCSJConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvCSJConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
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
