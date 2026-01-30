//
//  AdvanceCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol AdvanceCommonAdapter <NSObject>

@optional

- (void)adapter_setupWithAdapterId:(NSString *)adapterId
                       placementId:(NSString *)placementId
                            config:(NSDictionary *)config;

- (void)adapter_loadAd;

- (BOOL)adapter_isAdValid;

- (void)adapter_showAdInWindow:(UIWindow *)window;

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController;

- (void)adapter_render:(UIViewController *)rootViewController; //模板信息流使用

- (id)adapter_renderFeedAdWrapper; //自渲染信息流使用

- (id)adapter_bannerView; //Banner使用

//是否缓存广告对象
- (void)adapter_cacheAdapterIfNeeded:(id)adapter
                           adapterId:(NSString *)adapterId
                               price:(NSInteger)price;

@end

