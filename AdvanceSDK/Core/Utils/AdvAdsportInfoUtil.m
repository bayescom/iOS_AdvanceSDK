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
        if ([ID isEqualToString:SDK_ID_MERCURY]) { // mercury
            parallel = NO;
        } else if ([ID isEqualToString:SDK_ID_GDT]) {
            parallel = YES;
        } else if ([ID isEqualToString:SDK_ID_CSJ]) {
            parallel = YES;
        }
    } else {
        return NO;
    }
    return parallel;
}

@end
