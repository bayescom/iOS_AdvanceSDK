//
//  DemoRewardVideoViewController.m
//  AdvanceSDKDemo
//
//  Created by CherryKing on 2020/1/3.
//  Copyright © 2020 BAYESCOM. All rights reserved.
//

#import "DemoRewardVideoViewController.h"
#import <AdvanceSDK/AdvanceRewardVideo.h>

@interface DemoRewardVideoViewController () <AdvanceRewardedVideoDelegate>
@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
             
@end

@implementation DemoRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
//        @{@"addesc": @"激励视频", @"adspotId": @"100255-10002595"},
//        @{@"addesc": @"激励视频", @"adspotId": @"100255-10006516"},
        
        //@{@"addesc": @"激励视频-GroMore", @"adspotId": @"102768-10008583"},
        @{@"addesc": @"激励视频-Bidding", @"adspotId": @"102768-10008526"},
        @{@"addesc": @"激励视频-倍业", @"adspotId": @"102768-10007792"},
        @{@"addesc": @"激励视频-穿山甲", @"adspotId": @"102768-10007802"},
        @{@"addesc": @"激励视频-优量汇", @"adspotId": @"102768-10007811"},
        @{@"addesc": @"激励视频-快手", @"adspotId": @"102768-10007819"},
        @{@"addesc": @"激励视频-百度", @"adspotId": @"102768-10007837"},
        @{@"addesc": @"激励视频-Tanx", @"adspotId": @"102768-10009461"},
        @{@"addesc": @"激励视频-Sigmob", @"adspotId": @"102768-10011964"}
    ];
    
    self.btn1Title = @"加载广告";
    self.btn2Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }

    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:self.adspotId
                                                                 customExt:self.ext
                                                            viewController:self];
    self.advanceRewardVideo.delegate=self;
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    if (self.advanceRewardVideo.isAdValid) {
        [self.advanceRewardVideo showAd];
    }
}

// MARK: ======================= AdvanceRewardVideoDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error,description);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
    self.advanceRewardVideo.delegate = nil;
    self.advanceRewardVideo = nil;
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 激励视频广告数据拉取成功
- (void)didFinishLoadingRewardedVideoADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功, 正在缓存... %s", __func__);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
}

/// 激励视频缓存成功
- (void)rewardedVideoDidDownLoadForSpotId:(NSString *)spotId extra:(NSDictionary *)extra{
    NSLog(@"视频缓存成功 %s", __func__);
}

/// 激励视频开始播放
- (void)rewardedVideoDidStartPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 激励视频到达激励时间
- (void)rewardedVideoDidRewardSuccessForSpotId:(NSString *)spotId extra:(NSDictionary *)extra rewarded:(BOOL)rewarded {
    NSLog(@"到达激励时间 %s %d", __func__, rewarded);
}

/// 激励视频播放完成
- (void)rewardedVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"播放完成 %s", __func__);
}

/// 激励视频广告点击
- (void)rewardedVideoDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 激励视频广告关闭
- (void)rewardedVideoDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
    self.advanceRewardVideo.delegate = nil;
    self.advanceRewardVideo = nil;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
