//
//  DemoInterstitialViewController.m
//  advancelib
//
//  Created by allen on 2019/12/31.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "DemoInterstitialViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceInterstitial.h>

@interface DemoInterstitialViewController () <AdvanceInterstitialDelegate>
@property (nonatomic, strong) AdvanceInterstitial *advanceInterstitial;
@property (nonatomic) bool isAdLoaded;
@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10000559"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10006501"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"102194-10007006"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"102194-10007395"},
        @{@"addesc": @"插屏-倍业", @"adspotId": @"102768-10007791"},
        @{@"addesc": @"插屏-穿山甲", @"adspotId": @"102768-10007801"},
        @{@"addesc": @"插屏-优良汇", @"adspotId": @"102768-10007810"},
        @{@"addesc": @"插屏-快手", @"adspotId": @"102768-10007818"},
        @{@"addesc": @"插屏-百度", @"adspotId": @"102768-10007836"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    NSLog(@"%s", __func__);
    if (![self checkAdspotId]) { return; }
    

    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId
                                                              viewController:self
                                                                      adSize:CGSizeMake(414, 300)];
    self.advanceInterstitial.delegate = self;
    _isAdLoaded=false;
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    
    
    [self.advanceInterstitial showAd];
}

// MARK: ======================= AdvanceInterstitialDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功 %s", __func__);
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
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description {
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

}



/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);

}

/// 广告关闭了
- (void)advanceDidClose {
    NSLog(@"广告关闭了 %s", __func__);
}

/// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId {
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}


- (void)dealloc {
    NSLog(@"%s",__func__);

}

@end
