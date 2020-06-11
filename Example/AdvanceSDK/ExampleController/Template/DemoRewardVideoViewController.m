//
//  DemoRewardVideoViewController.m
//  AdvanceSDKDemo
//
//  Created by CherryKing on 2020/1/3.
//  Copyright © 2020 BAYESCOM. All rights reserved.
//

#import "DemoRewardVideoViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceRewardVideo.h>

@interface DemoRewardVideoViewController () <AdvanceRewardVideoDelegate>
@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
@property (nonatomic) bool isAdLoaded;
@end

@implementation DemoRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"激励视频", @"adspotId": @"100255-10002595"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:self.adspotId
                                                           viewController:self];
    self.advanceRewardVideo.delegate=self;
    [self.advanceRewardVideo setDefaultSdkSupplierWithMediaId:@"100255"
                                                     adspotId:@"10002595"
                                                     mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                     sdkId:SDK_ID_MERCURY];
    _isAdLoaded=false;
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    if (!_isAdLoaded) {
       [JDStatusBarNotification showWithStatus:@"请先加载广告" dismissAfter:1.5];
    }
    [self.advanceRewardVideo showAd];
}

// MARK: ======================= AdvanceRewardVideoDelegate =======================
- (void)advanceRewardVideoOnAdReady {
    NSLog(@"广告数据加载成功");
    _isAdLoaded=true;
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
}

- (void)advanceRewardVideoOnAdVideoCached
{
    NSLog(@"视频缓存成功");
    [JDStatusBarNotification showWithStatus:@"视频缓存成功" dismissAfter:1.5];

}

- (void)advanceRewardVideoAdDidRewardEffective {
    NSLog(@"到达激励时间");
}

- (void)advanceRewardVideoOnAdRenderFailed {
    NSLog(@"广告渲染失败");
}

- (void)advanceRewardVideoOnAdClicked {
    NSLog(@"广告点击");
}

- (void)advanceRewardVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告拉取失败");
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
}

- (void)advanceRewardVideoOnAdShow {
    NSLog(@"广告展示");
}

- (void)advanceRewardVideoOnAdClosed {
    NSLog(@"广告关闭");
}

- (void)advanceRewardVideoAdDidPlayFinish {
    NSLog(@"播放完成");
}

- (void)advanceRewardVideoIsReadyToShow {
    if (!_isAdLoaded) {
       [JDStatusBarNotification showWithStatus:@"请先加载广告" dismissAfter:1.5];
    }
    NSLog(@"播放可以Show");
    [self.advanceRewardVideo showAd];
}

@end
