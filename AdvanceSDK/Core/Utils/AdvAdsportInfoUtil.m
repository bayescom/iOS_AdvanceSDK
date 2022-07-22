//
//  AdvAdsportInfoUtil.m
//  AdvanceSDK
//
//  Created by MS on 2021/3/15.
//

#import "AdvAdsportInfoUtil.h"
#import "AdvSdkConfig.h"
@implementation AdvAdsportInfoUtil
+ (BOOL)isSupportParallelWithAdTypeName:(NSString *)adTypeName supplierId:(NSString *)ID {
    BOOL parallel = NO;
    
    if ([adTypeName isEqualToString:AdvSdkTypeAdNameSplash]) { // 开屏
        return YES;
    } else if ([adTypeName isEqualToString:AdvSdkTypeAdNameRewardVideo]) {
        return YES;
    } else if ([adTypeName isEqualToString:AdvSdkTypeAdNameInterstitial]){
        return YES;
    } else if ([adTypeName isEqualToString:AdvSdkTypeAdNameFullScreenVideo]){
        if ([ID isEqualToString:SDK_ID_MERCURY]) {
            return NO;
        } else {
            return YES;
        }
    } else if ([adTypeName isEqualToString:AdvSdkTypeAdNameNativeExpress]) {
        return YES;
    }
    return parallel;
}

@end
