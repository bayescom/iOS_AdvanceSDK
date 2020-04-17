//
//  DemoSplashViewController.m
//  AAA
//
//  Created by 程立卿 on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoSplashViewController.h"

#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200034"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceSplash = [[AdvanceSplash alloc] initWithMediaId:self.mediaId
                                                       adspotId:self.adspotId
                                                 viewController:self];
    self.advanceSplash.delegate=self;
    self.advanceSplash.logoImage= [UIImage imageNamed:@"640-100"];
    self.advanceSplash.backgroundImage= [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotid:@"10002436"
                                                mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkTag:SDK_TAG_MERCURY];
    [self.advanceSplash loadAd];
}

// MARK: ======================= advanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived {
    [DemoUtils showToast:@"广告数据拉取成功"];
}

/// 广告渲染失败
- (void)advanceSplashOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告曝光成功
- (void)advanceSplashOnAdShow {
    [DemoUtils showToast:@"广告曝光成功"];
}

/// 广告展示失败
- (void)advanceSplashOnAdFailed {
    [DemoUtils showToast:@"广告展示失败"];
}

/// 广告点击
- (void)advanceSplashOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

/// 广告关闭
- (void)advanceSplashOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}

@end
