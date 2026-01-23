#import "AdvanceBaseAdSpot.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceSplash;
@protocol AdvanceSplashDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onSplashAdDidLoad:(AdvanceSplash *)splashAd;

/// 广告加载失败回调
-(void)onSplashAdFailToLoad:(AdvanceSplash *)splashAd error:(NSError *)error;

/// 广告曝光回调
-(void)onSplashAdExposured:(AdvanceSplash *)splashAd;

/// 广告展示失败回调
-(void)onSplashAdFailToPresent:(AdvanceSplash *)splashAd error:(NSError *)error;

/// 广告点击回调
- (void)onSplashAdClicked:(AdvanceSplash *)splashAd;

/// 广告关闭回调
- (void)onSplashAdClosed:(AdvanceSplash *)splashAd;

@end

@interface AdvanceSplash : AdvanceBaseAdSpot

/// 广告代理
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

/// 用于广告跳转的视图控制器
@property (nonatomic, weak) UIViewController *viewController;

/// 开屏广告底部Logo视图
@property (nonatomic, strong) UIView *bottomLogoView;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceSplashDelegate>)delegate;

/// 加载广告
- (void)loadAd;

/// 展示广告
- (void)showAdInWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
