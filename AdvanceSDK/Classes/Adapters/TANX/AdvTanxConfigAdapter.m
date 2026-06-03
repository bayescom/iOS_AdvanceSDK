//
//  AdvTanxConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvTanxConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvError.h"

@interface AdvTanxConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvTanxConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    BOOL res = [TXAdSDKInitializtion setupSDKWithAppID:appId andAppKey:appkey];
    NSError *error = res? nil : [AdvError errorWithCode:AdvErrorCode_SupplierInitFailed].toNSError;
    completion? completion(error) : nil;
}

+ (NSString *)sdkVersion {
    return [TXAdSDKConfiguration sdkVersion];
}

@end
