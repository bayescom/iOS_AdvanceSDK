//
//  DemoRewardVideoViewController.m
//  AdvanceSDKDemo
//
//  Created by CherryKing on 2020/1/3.
//  Copyright © 2020 BAYESCOM. All rights reserved.
//

#import "DemoRewardVideoViewController.h"
#import <AdvanceSDK/AdvanceRewardVideo.h>

@interface DemoRewardVideoViewController () <AdvanceRewardVideoDelegate>
@property (nonatomic, strong) AdvanceRewardVideo *rewardVideoAd;
             
@end

@implementation DemoRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adspotIdsArr = @[
        //@{@"addesc": @"激励视频-GroMore", @"adspotId": @"102768-10008583"},
        // 10012265: 服务端激励验证
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
    self.rewardVideoAd = [[AdvanceRewardVideo alloc] initWithAdspotId:self.adspotId extra:nil delegate:self];
    
    // 奖励设置（可选）
    AdvRewardVideoModel *model = [[AdvRewardVideoModel alloc] init];
    model.userId = @"123456";
    model.rewardAmount = 100;
    model.rewardName = @"福利";
//    model.extra = @{@"key1" : @"value1"}.modelToJSONString; // 透传参数
    self.rewardVideoAd.rewardVideoModel = model;
    // 加载广告
    [self.rewardVideoAd loadAd];
}

- (void)loadAdBtn2Action {
    if (self.rewardVideoAd.isAdValid) {
        [self.rewardVideoAd showAdFromViewController:self];
    }
}

#pragma mark: - AdvanceRewardVideoDelegate
/// 广告加载成功回调
- (void)onRewardVideoAdDidLoad:(AdvanceRewardVideo *)rewardVideoAd {
    NSLog(@"激励视频广告加载成功 %s %@", __func__, rewardVideoAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
}

/// 广告加载失败回调
-(void)onRewardVideoAdFailToLoad:(AdvanceRewardVideo *)rewardVideoAd error:(NSError *)error {
    NSLog(@"激励视频广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.rewardVideoAd = nil;
}

/// 广告曝光回调
-(void)onRewardVideoAdExposured:(AdvanceRewardVideo *)rewardVideoAd {
    NSLog(@"激励视频广告曝光回调 %s %@", __func__, rewardVideoAd);
}

/// 广告展示失败回调
-(void)onRewardVideoAdFailToPresent:(AdvanceRewardVideo *)rewardVideoAd error:(NSError *)error {
    NSLog(@"激励视频广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.rewardVideoAd = nil;
}

/// 广告点击回调
- (void)onRewardVideoAdClicked:(AdvanceRewardVideo *)rewardVideoAd {
    NSLog(@"激励视频广告点击回调 %s %@", __func__, rewardVideoAd);
}

/// 广告关闭回调
- (void)onRewardVideoAdClosed:(AdvanceRewardVideo *)rewardVideoAd {
    NSLog(@"激励视频广告关闭回调 %s %@", __func__, rewardVideoAd);
    self.rewardVideoAd = nil;
}

/// 广告奖励发放成功回调
- (void)onRewardVideoAdDidRewardSuccess:(AdvanceRewardVideo *)rewardVideoAd rewardInfo:(AdvRewardCallbackInfo *)rewardInfo {
    NSLog(@"激励视频广告奖励发放成功回调 %s %@", __func__, rewardInfo);
}

/// 服务端验证奖励失败回调
- (void)onRewardVideoAdDidServerRewardFail:(AdvanceRewardVideo *)rewardVideoAd error:(NSError *)error {
    NSLog(@"服务端验证激励失败回调 %s %@", __func__, error);
}

/// 广告播放结束回调
- (void)onRewardVideoAdDidPlayFinish:(AdvanceRewardVideo *)rewardVideoAd {
    NSLog(@"激励视频播放完成 %s", __func__);
}

- (void)dealloc {
    
}

@end
