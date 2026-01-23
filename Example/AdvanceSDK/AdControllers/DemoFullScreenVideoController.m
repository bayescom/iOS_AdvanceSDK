//
//  DemoFullScreenVideoController.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "DemoFullScreenVideoController.h"
#import <AdvanceSDK/AdvanceFullScreenVideo.h>

@interface DemoFullScreenVideoController () <AdvanceFullScreenVideoDelegate>
@property (nonatomic, strong) AdvanceFullScreenVideo *fullscreenVideoAd;

@end

@implementation DemoFullScreenVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adspotIdsArr = @[
        @{@"addesc": @"全屏视频-Bidding", @"adspotId": @"102768-10008529"},
        @{@"addesc": @"全屏视频-穿山甲", @"adspotId": @"102768-10007829"},
        @{@"addesc": @"全屏视频-优量汇", @"adspotId": @"102768-10007832"},
        @{@"addesc": @"全屏视频-快手", @"adspotId": @"102768-10007830"},
        @{@"addesc": @"全屏视频-百度", @"adspotId": @"102768-10007838"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.fullscreenVideoAd = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId extra:nil delegate:self];
    // 加载广告
    [self.fullscreenVideoAd loadAd];
}

- (void)loadAdBtn2Action {
    if (self.fullscreenVideoAd.isAdValid) {
        [self.fullscreenVideoAd showAdFromViewController:self];
    }
}


#pragma mark: - AdvanceFullScreenVideoDelegate
/// 广告加载成功回调
- (void)onFullScreenVideoAdDidLoad:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告加载成功 %s %@", __func__, fullscreenVideoAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
}

/// 广告加载失败回调
-(void)onFullScreenVideoAdFailToLoad:(AdvanceFullScreenVideo *)fullscreenVideoAd error:(NSError *)error {
    NSLog(@"全屏视频广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.fullscreenVideoAd = nil;
}

/// 广告曝光回调
-(void)onFullScreenVideoAdExposured:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告曝光回调 %s %@", __func__, fullscreenVideoAd);
}

/// 广告展示失败回调
-(void)onFullScreenVideoAdFailToPresent:(AdvanceFullScreenVideo *)fullscreenVideoAd error:(NSError *)error {
    NSLog(@"全屏视频广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.fullscreenVideoAd = nil;
}

/// 广告点击回调
- (void)onFullScreenVideoAdClicked:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告点击回调 %s %@", __func__, fullscreenVideoAd);
}

/// 广告关闭回调
- (void)onFullScreenVideoAdClosed:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告关闭回调 %s %@", __func__, fullscreenVideoAd);
    self.fullscreenVideoAd = nil;
}

/// 广告播放结束回调
- (void)onFullScreenVideoAdDidPlayFinish:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频播放完成 %s", __func__);
}

@end
