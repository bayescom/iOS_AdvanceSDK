//
//  AdvKSConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvKSConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <KSAdSDK/KSAdSDK.h>

@interface AdvKSConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvKSConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    KSAdSDKConfiguration *config = [KSAdSDKConfiguration configuration];
    config.appId = appId;
    [KSAdSDKManager startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        completion? completion(error) : nil;
    }];
}

+ (NSString *)sdkVersion {
    return [KSAdSDKManager SDKVersion];
}

@end
