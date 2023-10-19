//
//  AdvBiddingManger.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import "AdvBiddingManger.h"
#import <ABUAdSDK/ABUAdSDK.h>

@interface AdvBiddingManger ()

@property (nonatomic, assign, class) BOOL sdkInitialized;

@end

static AdvPolicyModel *_policyModel = nil;
static BOOL _sdkInitialized = NO;

@implementation AdvBiddingManger

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
    AdvBiddingManger.policyModel = dataObject;
    if (!AdvBiddingManger.sdkInitialized) {
        AdvBiddingManger.sdkInitialized = YES;
        [ABUAdSDKManager setupSDKWithAppId:dataObject.gro_more.gromore_params.appid config:nil];
    }
}

@end
