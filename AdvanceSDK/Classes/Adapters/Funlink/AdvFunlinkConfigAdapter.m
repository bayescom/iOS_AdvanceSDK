//
//  AdvFunlinkConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvFunlinkConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvError.h"

@interface AdvFunlinkConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvFunlinkConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    BOOL res = [FLinkAdSDKManager registerAppId:appId];
    NSError *error = res? nil : [AdvError errorWithCode:AdvErrorCode_SupplierInitFailed].toNSError;
    completion? completion(error) : nil;
}

+ (NSString *)sdkVersion {
    return [FLinkAdSDKManager SDKVersion];
}

@end
