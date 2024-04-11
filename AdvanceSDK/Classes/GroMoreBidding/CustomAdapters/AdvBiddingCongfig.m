//
//  AdvBiddingConfig.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import "AdvBiddingCongfig.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import <AdvanceSDK/AdvSdkConfig.h>

@interface AdvBiddingCongfig () <ABUCustomConfigAdapter>

@end

@implementation AdvBiddingCongfig

#pragma mark - ABUCustomConfigAdapter

- (NSString * _Nonnull)adapterVersion {
    return @"1.0.0";
}

- (nonnull ABUCustomAdapterVersion *)basedOnCustomAdapterVersion {
    return ABUCustomAdapterVersion1_1;
}

- (void)initializeAdapterWithConfiguration:(ABUSdkInitConfig * _Nullable)initConfig {
    /// 用于初始化自定义ADN，因为AdvanceSDK早就初始化了，所以这边不需要再写
}

- (NSString * _Nonnull)networkSdkVersion {
    return [AdvSdkConfig sdkVersion];
}

- (void)didReceiveConfigUpdateRequest:(nonnull ABUUserConfig *)config {
    
}

- (void)didRequestAdPrivacyConfigUpdate:(nonnull NSDictionary *)config {
    
}

@end
