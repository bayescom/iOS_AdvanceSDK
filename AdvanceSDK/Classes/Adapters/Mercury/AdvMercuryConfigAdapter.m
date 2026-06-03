//
//  AdvMercuryConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvMercuryConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <MercurySDK/MercurySDK.h>

@interface AdvMercuryConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvMercuryConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    [MercuryConfigManager initWithAppId:appId appKey:appkey];
    [MercuryConfigManager startWithCompletionHandler:^(BOOL success, NSError *error) {
        completion? completion(error) : nil;
    }];
}

+ (NSString *)sdkVersion {
    return [MercuryConfigManager sdkVersion];
}

@end
