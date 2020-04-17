//
//  DemoRewardVideoViewController.m
//  AdvanceSDKDemo
//
//  Created by 程立卿 on 2020/1/3.
//  Copyright © 2020 BAYESCOM. All rights reserved.
//

#import "DemoRewardVideoViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceRewardVideo.h>

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
                                                     adspotid:@"10002595"
                                                     mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                       sdkTag:@"bayes"];
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceRewardVideo showAd];
}

// MARK: ======================= AdvanceRewardVideoDelegate =======================
- (void)advanceRewardVideoOnAdReady {
    NSLog(@"广告数据加载成功");
}

- (void)advanceRewardVideoOnAdVideoCached
{
    NSLog(@"视频缓存成功");
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

- (void)advanceRewardVideoOnAdFailedWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    NSLog(@"广告拉取失败");
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

@end
