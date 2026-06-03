//
//  AdvSigmobConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvSigmobConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <WindSDK/WindSDK.h>

@interface AdvSigmobConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvSigmobConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    WindAdOptions *options = [[WindAdOptions alloc] initWithAppId:appId appKey:appkey];
    [WindAds startWithOptions:options];
    completion? completion(nil) : nil;
}

+ (NSString *)sdkVersion {
    return [WindAds sdkVersion];
}

@end
