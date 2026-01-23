//
//  DemoSplashViewController.m
//  AAA
//
//  Created by CherryKing on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoSplashViewController.h"
#import <AdvanceSDK/AdvanceSplash.h>

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *splashAd;

@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        //@{@"addesc": @"开屏-GroMore", @"adspotId": @"102768-10008570"},
        @{@"addesc": @"开屏-Bidding", @"adspotId": @"102768-10008229"},
        @{@"addesc": @"开屏-倍业", @"adspotId": @"102768-10007788"},
        @{@"addesc": @"开屏-穿山甲", @"adspotId": @"102768-10007798"},
        @{@"addesc": @"开屏-优量汇", @"adspotId": @"102768-10007807"},
        @{@"addesc": @"开屏-快手", @"adspotId": @"102768-10007816"},
        @{@"addesc": @"开屏-百度", @"adspotId": @"102768-10007833"},
        @{@"addesc": @"开屏-Tanx", @"adspotId": @"102768-10009456"},
        @{@"addesc": @"开屏-Sigmob", @"adspotId": @"102768-10011989"}
    ];
    self.btn1Title = @"加载并展示广告";
    //    self.btn2Title = @"展示广告";
    
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.splashAd = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                      extra:@{@"testExt": @1}
                                                   delegate:self];
    self.splashAd.viewController = self;
    self.splashAd.bottomLogoView = [self createBottomLogoView];
    // 加载广告
    [self.splashAd loadAd];
}

- (void)showAdInWindow {
    if (self.splashAd.isAdValid) {
        [self.splashAd showAdInWindow:self.view.window];
    }
}

- (UIView *)createBottomLogoView {
    CGFloat width = self.view.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 120)];
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"app_logo"]];
    [view addSubview:imageV];
    imageV.frame = view.bounds;
    imageV.center = view.center;
    
    return view;
}

#pragma mark: - AdvanceSplashDelegate
/// 广告加载成功回调
- (void)onSplashAdDidLoad:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告加载成功 %s %@", __func__, splashAd);
//    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
    [self showAdInWindow];
}

/// 广告加载失败回调
-(void)onSplashAdFailToLoad:(AdvanceSplash *)splashAd error:(NSError *)error {
    NSLog(@"开屏广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.splashAd = nil;
}

/// 广告曝光回调
-(void)onSplashAdExposured:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告曝光回调 %s %@", __func__, splashAd);
}

/// 广告展示失败回调
-(void)onSplashAdFailToPresent:(AdvanceSplash *)splashAd error:(NSError *)error {
    NSLog(@"开屏广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.splashAd = nil;
}

/// 广告点击回调
- (void)onSplashAdClicked:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告点击回调 %s %@", __func__, splashAd);
}

/// 广告关闭回调
- (void)onSplashAdClosed:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告关闭回调 %s %@", __func__, splashAd);
    self.splashAd = nil;
}

- (void)dealloc {
    
}

@end
