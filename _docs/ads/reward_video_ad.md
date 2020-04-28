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
- (void)advanceRewardVideoOnAdReady {
    [DemoUtils showToast:@"广告数据加载成功"];
}

- (void)advanceRewardVideoOnAdVideoCached
{
    [DemoUtils showToast:@"视频缓存成功"];
}

- (void)advanceRewardVideoAdDidRewardEffective {
    [DemoUtils showToast:@"到达激励时间"];
}

- (void)advanceRewardVideoOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

- (void)advanceRewardVideoOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

- (void)advanceRewardVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    [DemoUtils showToast:@"广告拉取失败"];
}

- (void)advanceRewardVideoOnAdShow {
    [DemoUtils showToast:@"广告展示"];
}

- (void)advanceRewardVideoOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}

- (void)advanceRewardVideoAdDidPlayFinish {
    [DemoUtils showToast:@"播放完成"];
}

@end


```