#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 渠道描述只保存类，不提前创建广告对象或初始化渠道 SDK。
@interface AdvAdapterDescriptor : NSObject

@property (nonatomic, copy, readonly) NSString *supplierId;
@property (nonatomic, copy, readonly) NSString *versionParameterKey;
@property (nonatomic, readonly, nullable) Class configAdapterClass;
@property (nonatomic, readonly, nullable) Class splashAdapterClass;
@property (nonatomic, readonly, nullable) Class bannerAdapterClass;
@property (nonatomic, readonly, nullable) Class interstitialAdapterClass;
@property (nonatomic, readonly, nullable) Class rewardVideoAdapterClass;
@property (nonatomic, readonly, nullable) Class fullScreenVideoAdapterClass;
@property (nonatomic, readonly, nullable) Class nativeExpressAdapterClass;
@property (nonatomic, readonly, nullable) Class renderFeedAdapterClass;

- (instancetype)initWithSupplierId:(NSString *)supplierId
                   configClassName:(nullable NSString *)configClassName
                   splashClassName:(nullable NSString *)splashClassName
                   bannerClassName:(nullable NSString *)bannerClassName
             interstitialClassName:(nullable NSString *)interstitialClassName
              rewardVideoClassName:(nullable NSString *)rewardVideoClassName
          fullScreenVideoClassName:(nullable NSString *)fullScreenVideoClassName
            nativeExpressClassName:(nullable NSString *)nativeExpressClassName
               renderFeedClassName:(nullable NSString *)renderFeedClassName
               versionParameterKey:(NSString *)versionParameterKey;

@end

NS_ASSUME_NONNULL_END
