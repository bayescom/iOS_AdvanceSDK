//
//  AdvanceRenderFeed.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvRenderFeedAdWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceRenderFeed;
@protocol AdvanceRenderFeedDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onRenderFeedAdSuccessToLoad:(AdvanceRenderFeed *)renderFeedAd feedAdWrapper:(AdvRenderFeedAdWrapper *)feedAdWrapper;

/// 广告加载失败回调
- (void)onRenderFeedAdFailToLoad:(AdvanceRenderFeed *)renderFeedAd error:(NSError *)error;

/// 广告曝光回调
-(void)onRenderFeedAdViewExposured:(AdvRenderFeedAdWrapper *)feedAdWrapper;

/// 广告点击回调
- (void)onRenderFeedAdViewClicked:(AdvRenderFeedAdWrapper *)feedAdWrapper;

/// 广告关闭回调
- (void)onRenderFeedAdViewClosed:(AdvRenderFeedAdWrapper *)feedAdWrapper;

/// 广告详情页关闭回调
- (void)onRenderFeedAdDidCloseDetailPage:(AdvRenderFeedAdWrapper *)feedAdWrapper;

/// 视频广告播放结束回调
- (void)onRenderFeedAdDidPlayFinish:(AdvRenderFeedAdWrapper *)feedAdWrapper;

@end

/// 自渲染信息流广告
@interface AdvanceRenderFeed : AdvanceBaseAdSpot

/// 广告代理
@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

/// 用于广告跳转的视图控制器
@property (nonatomic, weak) UIViewController *viewController;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceRenderFeedDelegate>)delegate;

/// 加载广告
- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
