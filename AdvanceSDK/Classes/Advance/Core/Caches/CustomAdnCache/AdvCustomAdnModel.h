//
//  AdvCustomAdnModel.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/3.
//

#import <Foundation/Foundation.h>

#pragma mark: 自定义Adn list信息
@interface AdvCustomAdnListInfo : NSObject <NSCoding>
/**
 当发送version和目前adnlist的version版本一致时候，该字段返回为空，则表示不用更新adnlist信息。
 如果不一致时，该字段是全量adnlist信息。
*/
@property (nonatomic, strong) NSArray *custom_adn_list;
@property (nonatomic, copy) NSString *version; // 当前adn_list的版本信息

@end

#pragma mark: 自定义广告网络对象
@interface AdvCustomAdnModel : NSObject <NSCoding>
/// 自定义adn id
@property (nonatomic, copy) NSString *adnId;
/// 自定义adn 名称
@property (nonatomic, copy) NSString *adnName;
/// 自定义adapter 初始化的配置类名
@property (nonatomic, copy) NSString *customConfigAdapterClassName;
/// 自定义adapter 开屏广告的配置类名
@property (nonatomic, copy) NSString *customSplashAdapterClassName;
/// 自定义adapter banner广告的配置类名
@property (nonatomic, copy) NSString *customBannerAdapterClassName;
/// 自定义adapter 插屏广告的配置类名
@property (nonatomic, copy) NSString *customInterstitialAdapterClassName;
/// 自定义adapter 激励视频广告的配置类名
@property (nonatomic, copy) NSString *customRewardVideoAdapterClassName;
/// 自定义adapter 模板渲染信息流广告的配置类名
@property (nonatomic, copy) NSString *customNativeExpressAdapterClassName;
/// 自定义adapter 自渲染信息流广告的配置类名
@property (nonatomic, copy) NSString *customRenderFeedAdapterClassName;

@end

