## 插屏广告

插屏广告分为两个阶段，加载和展示。需要在广告加载成功后调用展示方法展示插屏广告。

```objective-c

#import "DemoInterstitialViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoInterstitialViewController () <AdvanceInterstitialDelegate>
@property (nonatomic, strong) AdvanceInterstitial *advanceInterstitial;

@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200043"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithMediaId:self.mediaId
                                                                   adspotId:self.adspotId
                                                             viewController:self];
    self.advanceInterstitial.delegate=self;
    [self.advanceInterstitial setDefaultSdkSupplierWithMediaId:@"100255"
                                                      adspotId:@"10000559"
                                                      mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkId:SDK_ID_MERCURY];
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceInterstitial showAd];
}

// MARK: ======================= AdvanceInterstitialDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceInterstitialOnAdReceived {
    [DemoUtils showToast:@"请求广告数据成功后调用"];
}

/// 广告准备就绪
- (void)advanceInterstitialOnAdReady {
    [DemoUtils showToast:@"广告准备就绪"];
}

/// 广告渲染失败
- (void)advanceInterstitialOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告曝光成功
- (void)advanceInterstitialOnAdShow {
    [DemoUtils showToast:@"广告曝光成功"];
}

/// 广告点击
- (void)advanceInterstitialOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

/// 广告拉取失败
- (void)advanceInterstitialOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    [DemoUtils showToast:@"广告拉取失败"];
}

/// 广告关闭
- (void)advanceInterstitialOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}

@end

```