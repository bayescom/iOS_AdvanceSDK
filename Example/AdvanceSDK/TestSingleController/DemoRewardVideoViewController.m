//
//  DemoRewardVideoViewController.m
//  AdvanceSDKDemo
//
//  Created by 程立卿 on 2020/1/3.
//  Copyright © 2020 BAYESCOM. All rights reserved.
//

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
                                                     adspotid:@"10002595"
                                                     mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                       sdkTag:SDK_TAG_MERCURY];
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceRewardVideo showAd];
}

// MARK: ======================= advanceRewardVideoDelegate =======================
- (void)advanceRewardVideoOnAdReady {
    [DemoUtils showToast:@"广告数据加载成功"];
}
- (void)advanceRewardVideoOnAdVideoCached
{
    [DemoUtils showToast:@"视频缓存成功"];

}

- (void)advanceRewardVideoOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

- (void)advanceRewardVideoOnAdFailed {
    [DemoUtils showToast:@"广告失败"];
}

- (void)advanceRewardVideoOnAdShow {
    [DemoUtils showToast:@"广告展示"];
}

- (void)advanceRewardVideoOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}


@end
