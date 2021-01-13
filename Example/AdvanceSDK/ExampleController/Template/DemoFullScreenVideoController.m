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
        @{@"addesc": @"Mock 渠道错误", @"adspotId": @"100255-10000001"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    
//    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:@"11111112"
//                                                                    viewController:self];

//    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId
//                                                                    viewController:self];
    
    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId
                                                                         customExt:self.ext
                                                                    viewController:self];
    self.advanceFullScreenVideo.delegate = self;
    [self.advanceFullScreenVideo setDefaultAdvSupplierWithMediaId:@"100255"
                                                      adspotId:@"10000559"
                                                      mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkId:SDK_ID_MERCURY];
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
- (void)advanceFullScreenVideoOnAdReceived {
    NSLog(@"请求广告数据成功后调用");
    _isAdLoaded=true;
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];

}

/// 广告渲染失败
- (void)advanceFullScreenVideoOnAdRenderFailed {
    NSLog(@"广告渲染失败");
}

/// 广告曝光
- (void)advanceExposured {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 广告点击
- (void)advanceClicked {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告拉取失败
- (void)advanceFullScreenVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告拉取失败");
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];

}

/// 广告关闭
- (void)advanceFullScreenVideoOnAdClosed {
    NSLog(@"广告关闭");
}

/// 广告播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish {
    NSLog(@"广告播放完成");
}

- (void)advanceOnAdNotFilled:(NSError *)error
{
    NSLog(@"策略加载失败");
}

- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

@end
