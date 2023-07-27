//
//  DemoFullScreenVideoController.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "DemoFullScreenVideoController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceFullScreenVideo.h>

@interface DemoFullScreenVideoController () <AdvanceFullScreenVideoDelegate>
@property (nonatomic, strong) AdvanceFullScreenVideo *advanceFullScreenVideo;
@property (nonatomic) bool isAdLoaded;

@end

@implementation DemoFullScreenVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10004765"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    
//    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:@"11111112"
//                                                                    viewController:self];

    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId
                                                                    viewController:self];
    
//    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId
//                                                                         customExt:self.ext
//                                                                    viewController:self];
    self.advanceFullScreenVideo.delegate = self;
    _isAdLoaded=false;
    [self.advanceFullScreenVideo loadAd];
}

- (void)loadAdBtn2Action {
    if (!_isAdLoaded) {
        [JDStatusBarNotification showWithStatus:@"请先加载广告" dismissAfter:1.5];

    }
    [self.advanceFullScreenVideo showAd];
}

// MARK: ======================= AdvanceFullScreenVideoDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略加载失败
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 全屏视频广告数据拉取成功
- (void)didFinishLoadingFullscreenVideoADWithSpotId:(NSString *)spotId {
    NSLog(@"请求广告数据成功后调用 %s", __func__);
}

/// 全屏视频存成功
- (void)fullscreenVideoDidDownLoadForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告缓存成功 %s", __func__);
    _isAdLoaded=true;
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
    [self loadAdBtn2Action];

}

/// 全屏视频开始播放
- (void)fullscreenVideoDidStartPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 全屏视频播放完成
- (void)fullscreenVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告播放完成 %s", __func__);
}

/// 全屏视频广告点击
- (void)fullscreenVideoDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 全屏视频点击跳过
- (void)fullscreenVideoDidClickSkipForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"点击了跳过 %s", __func__);
}

/// 全屏视频广告关闭
- (void)fullscreenVideoDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
}



@end
