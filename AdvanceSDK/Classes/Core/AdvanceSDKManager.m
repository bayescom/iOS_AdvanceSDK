//
//  AdvanceSDKManager.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/3.
//

#import "AdvanceSDKManager.h"
#import "AdvConstantHeader.h"
#import "AdvApiService.h"
#import "AdvCustomAdnCacheManager.h"

@implementation AdvanceSDKManager

+ (void)setAppId:(NSString *)appId {
    [AdvDeviceManager sharedInstance].appId = appId;
    [AdvanceSDKManager updateCustomAdnListInfo];
}

+ (NSString *)sdkVersion {
    return AdvanceSDKVersion;
}

+ (void)openDebug:(BOOL)enable {
    [AdvLog setLogEnable:enable];
}

+ (void)openAdTrack:(BOOL)enable {
    [AdvDeviceManager sharedInstance].isAdTrack = enable;
}

+ (void)updateCustomAdnListInfo {
    // 从缓存中获取adnlist信息
    AdvCustomAdnListInfo *cacheInfo = [[AdvCustomAdnCacheManager sharedInstance] customAdnlistInfo];
    [AdvApiService getCustomAdnlistInfoWithVersion:cacheInfo.version completion:^(AdvCustomAdnListInfo * _Nonnull info, NSError * _Nonnull error) {
        // 更新adnlist缓存
        if (info.custom_adn_list.count) {
            [[AdvCustomAdnCacheManager sharedInstance] cacheCustomAdnlistInfo:info];
        }
    }];
}

@end
