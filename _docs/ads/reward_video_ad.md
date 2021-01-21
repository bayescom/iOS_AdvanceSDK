## 激励视频

激励视频分为广告数据加载，视频缓存，以及展示阶段，当视频缓存成功回调后可以调用展示方法展示激励视频，激励视频在展示的过程中无法被关闭。

```objective-c

#import "DemoRewardVideoViewController.h"
#import "DemoUtils.h"
#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoRewardVideoViewController () <AdvanceRewardVideoDelegate>
@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
@end

@implementation DemoRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"激励视频", @"adspotId": @"10033-200045"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithMediaId:self.mediaId
                                                                 adspotId:self.adspotId
                                                           viewController:self];
    self.advanceRewardVideo.delegate=self;
    [self.advanceRewardVideo setDefaultSdkSupplierWithMediaId:@"100255"
                                                     adspotId:@"10002595"
                                                     mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                       sdkId:SDK_ID_MERCURY];
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceRewardVideo showAd];
}

// MARK: ======================= AdvanceRewardVideoDelegate =======================
/// 广告数据加载成功
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据加载成功 %s", __func__);
}

/// 视频缓存成功
- (void)advanceRewardVideoOnAdVideoCached {
    NSLog(@"视频缓存成功 %s", __func__);
}

/// 到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective {
    NSLog(@"到达激励时间 %s", __func__);
}

/// 广告曝光
- (void)advanceExposured {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 广告点击
- (void)advanceClicked {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error {
    NSLog(@"广告展示失败 %s  error: %@", __func__, error);
}

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);
}

/// 广告关闭
- (void)advanceDidClose {
    NSLog(@"广告关闭了 %s", __func__);
}

/// 播放完成
- (void)advanceRewardVideoAdDidPlayFinish {
    NSLog(@"播放完成 %s", __func__);
}

/// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId {
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

/// 广告可以被调用
- (void)advanceRewardVideoIsReadyToShow {
    NSLog(@"广告可以被调用了 %s", __func__);
}
@end


```