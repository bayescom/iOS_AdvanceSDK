//
//  AdvBayesSDKConfig.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/13.
//

#import "AdvBayesSDKConfig.h"

@implementation AdvBayesSDKConfig

static AdvBayesSDKConfig *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (void)setUserAgent:(NSString *)ua {
    [AdvBayesSDKConfig sharedInstance].userAgent = ua;
}

+ (void)setAAIDWithMediaId:(NSString *)mediaId
               mediaSecret:(NSString *)mediaSecret {
    [AdvBayesSDKConfig sharedInstance].aliMediaId = mediaId;
    [AdvBayesSDKConfig sharedInstance].aliMediaSecret = mediaSecret;
}

@end
