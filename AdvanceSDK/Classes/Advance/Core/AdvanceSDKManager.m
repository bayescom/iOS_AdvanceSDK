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
#import "AdvError.h"

@implementation AdvanceSDKManager

+ (void)startWithAppId:(NSString *)appId
            completion:(void (^)(NSError * _Nullable error))completion {
    if (!appId.length) {
        completion([AdvError errorWithCode:AdvErrorCode_SDKInitException].toNSError);
        return;
    }

    [AdvDeviceManager sharedInstance].appId = appId;
    AdvCustomAdnCacheManager *cacheManager = [AdvCustomAdnCacheManager sharedInstance];
    AdvCustomAdnListInfo *cacheInfo = [cacheManager customAdnlistInfo];

    if (cacheInfo) {
        // 已有当前AppId的缓存，可以立即请求广告；更新操作不影响本次初始化结果。
        completion(nil);
        [self updateCustomAdnListInfoWithCacheInfo:cacheInfo];
        return;
    }

    // 首次安装必须先准备好自定义ADN映射，再允许请求广告。
    [AdvApiService getCustomAdnlistInfoWithVersion:nil completion:^(AdvCustomAdnListInfo * _Nullable info, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        [cacheManager cacheCustomAdnlistInfo:info];
        completion(nil);
    }];
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

+ (void)updateCustomAdnListInfoWithCacheInfo:(AdvCustomAdnListInfo *)cacheInfo {
    [AdvApiService getCustomAdnlistInfoWithVersion:cacheInfo.version completion:^(AdvCustomAdnListInfo * _Nullable info, NSError * _Nullable error) {
        if (!error && info.custom_adn_list.count) {
            [[AdvCustomAdnCacheManager sharedInstance] cacheCustomAdnlistInfo:info];
        }
    }];
}

@end
