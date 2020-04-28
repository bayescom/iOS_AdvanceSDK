## 横幅广告

横幅广告需要设置广告容器，当前的ViewController作为参数。开发者可以设置广告轮播时间控制广告轮播时间，默认轮播时间为30秒。

```objective-c

#import "DemoBannerViewController.h"
#import "ViewBuilder.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoBannerViewController () <AdvanceBannerDelegate>
@property (nonatomic, strong) AdvanceBanner *advanceBanner;
@property (nonatomic, strong) UIView *contentV;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"Banner", @"adspotId": @"10033-200031"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    if (!_contentV) {
        _contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/6.4)];
    }
    [self.adShowView addSubview:self.contentV];
    self.adShowView.hidden = NO;
    
    self.advanceBanner = [[AdvanceBanner alloc] initWithMediaId:self.mediaId adspotId:self.adspotId adContainer:self.contentV viewController:self];
    self.advanceBanner.delegate = self;
    [self.advanceBanner setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotId:@"10000558"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkId:SDK_ID_MERCURY];
    [self.advanceBanner loadAd];
}

// MARK: ======================= AdvanceBannerDelegate =======================
/// 广告数据拉取成功回调
- (void)advanceBannerOnAdReceived {
    [DemoUtils showToast:@"广告数据拉取成功回调"];
}

/// banner条曝光回调
- (void)advanceBannerOnAdShow {
    [DemoUtils showToast:@"广告曝光回调"];
}

/// 广告渲染失败
- (void)advanceBannerOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告点击回调
- (void)advanceBannerOnAdClicked {
    [DemoUtils showToast:@"广告点击回调"];
}

/// 请求广告数据失败后调用
- (void)advanceBannerOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    [DemoUtils showToast:@"请求广告数据失败后调用"];
}

/// 广告关闭回调
- (void)advanceBannerOnAdClosed {
    [DemoUtils showToast:@"广告关闭回调"];
}

@end

```