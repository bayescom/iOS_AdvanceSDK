//
//  AdvGDTConfigAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/2.
//

#import "AdvGDTConfigAdapter.h"
#import "AdvanceCommonConfigAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>

@interface AdvGDTConfigAdapter () <AdvanceCommonConfigAdapter>

@end

@implementation AdvGDTConfigAdapter

+ (void)initializeAdapterWithAppId:(NSString *)appId appKey:(NSString *)appkey completion:(void (^)(NSError *error))completion {
    [GDTSDKConfig initWithAppId:appId];
    [GDTSDKConfig startWithCompletionHandler:^(BOOL success, NSError *error) {
        completion? completion(error) : nil;
    }];
}

+ (NSString *)sdkVersion {
    return [GDTSDKConfig sdkVersion];
}

@end
