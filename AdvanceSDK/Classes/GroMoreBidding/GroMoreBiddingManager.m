//
//  GroMoreBiddingManager.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import "GroMoreBiddingManager.h"
#import <ABUAdSDK/ABUAdSDK.h>

@interface GroMoreBiddingManager ()

@property (nonatomic, assign, class) BOOL sdkInitialized;

@end

static AdvPolicyModel *_policyModel = nil;
static BOOL _sdkInitialized = NO;

@implementation GroMoreBiddingManager

+ (AdvPolicyModel *)policyModel {
    return _policyModel;
}

+ (void)setPolicyModel:(AdvPolicyModel *)policyModel {
    _policyModel = policyModel;
}

+ (BOOL)sdkInitialized {
    return _sdkInitialized;
}

+ (void)setSdkInitialized:(BOOL)sdkInitialized {
    _sdkInitialized = sdkInitialized;
}

+ (void)loadGroMoreSDKWithDataObject:(AdvPolicyModel *)dataObject {
    GroMoreBiddingManager.policyModel = dataObject;
    if (!GroMoreBiddingManager.sdkInitialized) {
        GroMoreBiddingManager.sdkInitialized = YES;
        [ABUAdSDKManager initSDKWithAppId:dataObject.gro_more.gromore_params.appid config:^ABUUserConfig * _Nonnull(ABUUserConfig * _Nonnull config) {
#ifdef DEBUG
            // 打开日志开关，线上环境关闭
            config.logEnable = YES;
#endif
            return config;
        }];
        [ABUAdSDKManager setup];
    }
}

@end
