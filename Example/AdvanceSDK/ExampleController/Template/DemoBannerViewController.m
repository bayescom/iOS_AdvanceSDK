//
//  DemoBannerViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoBannerViewController.h"
#import "ViewBuilder.h"
#import "AdvSdkConfig.h"
#import "AdvanceBanner.h"


@interface DemoBannerViewController () <AdvanceBannerDelegate>
@property (nonatomic, strong) AdvanceBanner *advanceBanner;
@property (nonatomic, strong) UIView *contentV;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"Banner", @"adspotId": @"100255-10000558"},
        @{@"addesc": @"Mock 渠道错误", @"adspotId": @"100255-10000001"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    if (!_contentV) {
        _contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/6.4)];
    }
    [self.adShowView addSubview:self.contentV];
    self.adShowView.hidden = NO;

//    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:@"11111113" adContainer:self.contentV viewController:self];
//    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId adContainer:self.contentV viewController:self];
    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId adContainer:self.contentV customExt:self.ext viewController:self];
    self.advanceBanner.delegate = self;
    [self.advanceBanner setDefaultAdvSupplierWithMediaId:@"100255"
                                                adspotId:@"10000558"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkId:SDK_ID_MERCURY];
    
    [self.advanceBanner loadAd];
    
}

// MARK: ======================= AdvanceBannerDelegate =======================
/// 广告数据拉取成功回调
- (void)advanceBannerOnAdReceived {
    NSLog(@"广告数据拉取成功回调");
}

/// banner条曝光回调
- (void)advanceBannerOnAdShow {
    NSLog(@"广告曝光回调");
}

/// 广告点击回调
- (void)advanceBannerOnAdClicked {
    NSLog(@"广告点击回调");
}

/// 请求广告数据失败后调用
- (void)advanceBannerOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"请求广告数据失败后调用");
}

/// 广告关闭回调
- (void)advanceBannerOnAdClosed {
    NSLog(@"广告关闭回调");
}

/// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId {
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

/// 策略请求失败
- (void)advanceOnAdNotFilled:(NSError *)error {
    NSLog(@"策略请求失败");
}

@end
