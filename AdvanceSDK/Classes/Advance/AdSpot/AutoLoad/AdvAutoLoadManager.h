//
//  AdvAutoLoadManager.h
//  AdvanceSDK
//

#import <Foundation/Foundation.h>

@class AdvSupplier;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AdvAutoLoadAdType) {
    AdvAutoLoadAdTypeSplash,
    AdvAutoLoadAdTypeBanner,
    AdvAutoLoadAdTypeInterstitial,
    AdvAutoLoadAdTypeRewardVideo,
    AdvAutoLoadAdTypeFullscreenVideo,
    AdvAutoLoadAdTypeNativeExpress,
    AdvAutoLoadAdTypeRenderFeed,
};

/// 各广告类型自动预加载的内部协调器。
@interface AdvAutoLoadManager : NSObject

+ (instancetype)sharedInstance;

- (void)preloadAdspotId:(NSString *)adspotId
                  extra:(nullable NSDictionary *)extra
           adspotConfig:(NSDictionary *)adspotConfig
               supplier:(AdvSupplier *)supplier
                 adType:(AdvAutoLoadAdType)adType;

@end

NS_ASSUME_NONNULL_END
