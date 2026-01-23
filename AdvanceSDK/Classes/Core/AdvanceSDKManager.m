//
//  AdvanceSDKManager.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/3.
//

#import "AdvanceSDKManager.h"
#import "AdvConstantHeader.h"

@implementation AdvanceSDKManager

+ (void)setAppId:(NSString *)appId {
    [AdvDeviceManager sharedInstance].appId = appId;
}

+ (NSString *)sdkVersion {
    return AdvanceSDKVersion;
}

+ (void)openDebug:(BOOL)enable {
    [AdvLog setLogEnable:enable];
}

+ (void)openAdTrack:(BOOL)open {
    [AdvDeviceManager sharedInstance].isAdTrack = open;
}

@end
