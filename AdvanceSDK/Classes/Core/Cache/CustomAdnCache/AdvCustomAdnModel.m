//
//  AdvCustomAdnModel.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/3.
//

#import "AdvCustomAdnModel.h"

@implementation AdvCustomAdnListInfo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"custom_adn_list" : [AdvCustomAdnModel class]};
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.custom_adn_list = [aDecoder decodeObjectForKey:@"custom_adn_list"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
    }
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.custom_adn_list forKey:@"custom_adn_list"];
    [aCoder encodeObject:self.version forKey:@"version"];
}

@end


@implementation AdvCustomAdnModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"adnId": @"id",
        @"adnName": @"name",
        @"adnTag": @"tag",
        @"customConfigAdapterClassName": @"custom_config_adapter",
        @"customSplashAdapterClassName": @"custom_splash_adapter",
        @"customBannerAdapterClassName": @"custom_banner_adapter",
        @"customInterstitialAdapterClassName": @"custom_interstitial_adapter",
        @"customRewardVideoAdapterClassName": @"custom_rewardvideo_adapter",
        @"customNativeExpressAdapterClassName": @"custom_nativeexpress_adapter",
        @"customRenderFeedAdapterClassName": @"custom_renderfeed_adapter",
    };
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.adnId = [aDecoder decodeObjectForKey:@"adnId"];
        self.adnName = [aDecoder decodeObjectForKey:@"adnName"];
        self.adnTag = [aDecoder decodeObjectForKey:@"adnTag"];
        self.customConfigAdapterClassName = [aDecoder decodeObjectForKey:@"customConfigAdapterClassName"];
        self.customSplashAdapterClassName = [aDecoder decodeObjectForKey:@"customSplashAdapterClassName"];
        self.customBannerAdapterClassName = [aDecoder decodeObjectForKey:@"customBannerAdapterClassName"];
        self.customInterstitialAdapterClassName = [aDecoder decodeObjectForKey:@"customInterstitialAdapterClassName"];
        self.customRewardVideoAdapterClassName = [aDecoder decodeObjectForKey:@"customRewardVideoAdapterClassName"];
        self.customNativeExpressAdapterClassName = [aDecoder decodeObjectForKey:@"customNativeExpressAdapterClassName"];
        self.customRenderFeedAdapterClassName = [aDecoder decodeObjectForKey:@"customRenderFeedAdapterClassName"];
    }
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.adnId forKey:@"adnId"];
    [aCoder encodeObject:self.adnName forKey:@"adnName"];
    [aCoder encodeObject:self.adnTag forKey:@"adnTag"];
    [aCoder encodeObject:self.customConfigAdapterClassName forKey:@"customConfigAdapterClassName"];
    [aCoder encodeObject:self.customSplashAdapterClassName forKey:@"customSplashAdapterClassName"];
    [aCoder encodeObject:self.customBannerAdapterClassName forKey:@"customBannerAdapterClassName"];
    [aCoder encodeObject:self.customInterstitialAdapterClassName forKey:@"customInterstitialAdapterClassName"];
    [aCoder encodeObject:self.customRewardVideoAdapterClassName forKey:@"customRewardVideoAdapterClassName"];
    [aCoder encodeObject:self.customNativeExpressAdapterClassName forKey:@"customNativeExpressAdapterClassName"];
    [aCoder encodeObject:self.customRenderFeedAdapterClassName forKey:@"customRenderFeedAdapterClassName"];
}

@end
