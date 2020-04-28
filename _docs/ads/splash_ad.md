## 开屏广告

开屏广告需要传入当前ViewController作为参数，开屏广告展示时间统一为5秒钟，开发者可以设置统一的广告请求超时时间，超时时间默认为5秒。

```objective-c

#import "DemoSplashViewController.h"
#import "DemoUtils.h"
#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200034"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceSplash = [[AdvanceSplash alloc] initWithMediaId:self.mediaId
                                                       adspotId:self.adspotId
                                                 viewController:self];
    self.advanceSplash.delegate=self;
    self.advanceSplash.logoImage= [UIImage imageNamed:@"640-100"];
    self.advanceSplash.backgroundImage= [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotId:@"10002436"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkTag:SDK_ID_MERCURY];
    [self.advanceSplash loadAd];
}

// MARK: ======================= AdvanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived {
    [DemoUtils showToast:@"广告数据拉取成功"];
}

/// 广告渲染失败
- (void)advanceSplashOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告曝光成功
- (void)advanceSplashOnAdShow {
    [DemoUtils showToast:@"广告曝光成功"];
}

/// 广告展示失败
- (void)advanceSplashOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    [DemoUtils showToast:@"广告展示失败"];
}

/// 广告点击
- (void)advanceSplashOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked {
    [DemoUtils showToast:@"广告点击跳过"];
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
    [DemoUtils showToast:@"广告倒计时结束"];
}

@end

```