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
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@property (nonatomic, strong) UIImageView *backgroundImgView;

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
    [self.view.window addSubview:self.backgroundImgView];
    if (self.advanceSplash) {
        self.advanceSplash.delegate = nil;
        self.advanceSplash = nil;
    }
    
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                       customExt:@{@"testExt": @1}
                                                  viewController:self];
    self.advanceSplash.delegate = self;
//    self.advanceSplash.bottomLogoView = [self createBottomLogoView];
    // 加载广告
    [self.advanceSplash loadAd];
}

- (void)loadAdBtn2Action {
    if (self.advanceSplash.isAdValid) {
        [self.advanceSplash showInWindow:self.view.window];
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

// MARK: ======================= AdvanceSplashDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    [self removeBackgroundImgView];
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 开屏广告数据拉取成功
- (void)didFinishLoadingSplashADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    [self loadAdBtn2Action];
}

/// 广告曝光成功
- (void)splashDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光成功 %s", __func__);
    // 移除背景图
    [self removeBackgroundImgView];
}

/// 广告点击
- (void)splashDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)splashDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
    self.advanceSplash = nil;
}

- (void)removeBackgroundImgView {
    [self.backgroundImgView removeFromSuperview];
    self.backgroundImgView = nil;
}


- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] init];
        _backgroundImgView.frame = [UIScreen mainScreen].bounds;
        _backgroundImgView.image = [UIImage imageNamed:@"LaunchImage_img"];
    }
    return _backgroundImgView;
}

- (void)dealloc {
    
}

@end
