#import "AdvAdapterDescriptor.h"

@implementation AdvAdapterDescriptor

- (instancetype)initWithSupplierId:(NSString *)supplierId
                   configClassName:(NSString *)configClassName
                   splashClassName:(NSString *)splashClassName
                   bannerClassName:(NSString *)bannerClassName
             interstitialClassName:(NSString *)interstitialClassName
              rewardVideoClassName:(NSString *)rewardVideoClassName
          fullScreenVideoClassName:(NSString *)fullScreenVideoClassName
            nativeExpressClassName:(NSString *)nativeExpressClassName
               renderFeedClassName:(NSString *)renderFeedClassName
               versionParameterKey:(NSString *)versionParameterKey {
    if (self = [super init]) {
        _supplierId = [supplierId copy];
        _versionParameterKey = [versionParameterKey copy];
        _configAdapterClass = configClassName.length ? NSClassFromString(configClassName) : Nil;
        _splashAdapterClass = splashClassName.length ? NSClassFromString(splashClassName) : Nil;
        _bannerAdapterClass = bannerClassName.length ? NSClassFromString(bannerClassName) : Nil;
        _interstitialAdapterClass = interstitialClassName.length ? NSClassFromString(interstitialClassName) : Nil;
        _rewardVideoAdapterClass = rewardVideoClassName.length ? NSClassFromString(rewardVideoClassName) : Nil;
        _fullScreenVideoAdapterClass = fullScreenVideoClassName.length ? NSClassFromString(fullScreenVideoClassName) : Nil;
        _nativeExpressAdapterClass = nativeExpressClassName.length ? NSClassFromString(nativeExpressClassName) : Nil;
        _renderFeedAdapterClass = renderFeedClassName.length ? NSClassFromString(renderFeedClassName) : Nil;
    }
    return self;
}

@end
