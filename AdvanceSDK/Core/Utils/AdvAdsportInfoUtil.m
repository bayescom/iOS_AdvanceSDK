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
    
    if ([adTypeName isEqualToString:AdvSdkTypeAdNameSplash]) { // 开屏
        if ([ID isEqualToString:SDK_ID_MERCURY]) { // mercury
            return NO;
        } else if ([ID isEqualToString:SDK_ID_GDT]) {
            return YES;
        } else if ([ID isEqualToString:SDK_ID_CSJ]) {
            return YES;
        } else if ([ID isEqualToString:SDK_ID_KS]) {
            return YES;
        } else if ([ID isEqualToString:SDK_ID_BAIDU]) {
            return YES;
        } else if ([ID isEqualToString:SDK_ID_TANX]) {
            return YES;
        }
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
    return NO;
}

@end
