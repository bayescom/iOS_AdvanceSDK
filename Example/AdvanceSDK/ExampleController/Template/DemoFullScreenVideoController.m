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
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10003014"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10004765"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10004567"},
        @{@"addesc": @"Mock 渠道错误", @"adspotId": @"100255-10000001"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10003321"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-100070001"},
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

/// 请求广告数据成功后调用
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"请求广告数据成功后调用 %s", __func__);
    _isAdLoaded=true;
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
    [self loadAdBtn2Action];
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
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
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

/// 广告播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish {
    NSLog(@"广告播放完成 %s", __func__);
}

/// 策略加载成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

@end
