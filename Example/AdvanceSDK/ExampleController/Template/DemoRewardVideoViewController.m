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
@property (nonatomic) bool isAdLoaded; // 激励视频播放器 采用的是边下边播的方式, 理论上拉取数据成功 即可展示, 但如果网速慢导致缓冲速度慢, 则激励视频会出现卡顿
                                       // 广点通推荐在 advanceRewardVideoOnAdVideoCached 视频缓冲完成后 在掉用showad
@end

@implementation DemoRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"激励视频", @"adspotId": @"100255-10002595"},
        @{@"addesc": @"Mock 渠道错误", @"adspotId": @"100255-10000001"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10003321"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10009988"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10004405"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-100050002"},
        @{@"addesc": @"Mock code200", @"adspotId": @"102036-10006215"},
    ];
    
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }

    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:self.adspotId
                                                           viewController:self];
//    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:self.adspotId
//                                                                 customExt:self.ext
//                                                            viewController:self];
    self.advanceRewardVideo.delegate=self;
    _isAdLoaded=false;
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    if (!_isAdLoaded) {
       [JDStatusBarNotification showWithStatus:@"广告物料还没加载好" dismissAfter:1.5];
        return;;
    }
    [self.advanceRewardVideo showAd];
}

// MARK: ======================= AdvanceRewardVideoDelegate =======================
/// 广告数据加载成功
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功, 正在缓存... %s", __func__);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
//    [self loadAdBtn2Action];
}

/// 视频缓存成功
- (void)advanceRewardVideoOnAdVideoCached
{
    NSLog(@"视频缓存成功 %s", __func__);
    [JDStatusBarNotification showWithStatus:@"视频缓存成功" dismissAfter:1.5];
    _isAdLoaded=true;
    [self loadAdBtn2Action];
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
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error,description);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];

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
- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}


@end
