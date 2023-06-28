//
//  DemoSplashViewController.m
//  AAA
//
//  Created by CherryKing on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoSplashViewController.h"

#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSplash.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIApplication+Adv.h"
@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@property (nonatomic, strong) UIImageView *bgImgV;

@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     - 超时时间只需要设置AdvanceSplash的 timeout属性, 如果在timeout时间内没有广告曝光, 则会强制移除开屏广告,并触发错误回调

     - 每次加载需开屏广告需使用最新的实例, 不要进行本地存储, 或计时器持有的操作

     - 保证在开屏广告生命周期内(包括请求,曝光成功后的展现时间内),不要更换rootVC, 也不要对Window进行操作

     */
    // demo 中的id 为开发环境id
    // 需要id调试的媒体请联系运营同学开通
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10006483"},
        
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"101959-10006038"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"101959-10006806"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"102342-10006833"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"102342-10006591"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"111111-10007675"},
        
        @{@"addesc": @"开屏-倍业", @"adspotId": @"102768-10007788"},
        @{@"addesc": @"开屏-穿山甲", @"adspotId": @"102768-10007798"},
        @{@"addesc": @"开屏-优良汇", @"adspotId": @"102768-10007807"},
        @{@"addesc": @"开屏-快手", @"adspotId": @"102768-10007816"},
        @{@"addesc": @"开屏-百度", @"adspotId": @"102768-10007833"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"展示广告";


}

- (void)loadAdBtn2Action {
    [self.advanceSplash showInWindow:self.view.window];
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    
    [self.view.window addSubview:self.bgImgV];
    self.bgImgV.image = [UIImage imageNamed:@"LaunchImage_img"];
    
    
    
    if (self.advanceSplash) {
        self.advanceSplash.delegate = nil;
        self.advanceSplash = nil;
    }
    
    // 每次加载广告请 使用新的实例  不要用懒加载, 不要对广告对象进行本地化存储相关的操作
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                       customExt:@{} viewController:self];

    self.advanceSplash.isUploadSDKVersion = YES;
    self.advanceSplash.delegate = self;
    
    /**
      logo图片不应该是仅是一张透明的logo 应该是一张有背景的logo, 且高度等于你设置的logo高度
     
      self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];

     */
    
    // 如果想要对logo有特定的布局 则参照 -createLogoImageFromView 方法
    // 建议设置logo 避免某些素材长图不足时屏幕下方留白
    self.advanceSplash.logoImage = [self createLogoImageFromView];
    
    // 设置logo时 该属性要设置为YES
    self.advanceSplash.showLogoRequire = YES;

    
    
    // 如果该时间内没有广告返回 即:未触发-advanceUnifiedViewDidLoad 回调, 则会结束本次广告加载,并触发错误回调
    self.advanceSplash.timeout = 5;//<---- 确保timeout 时长内不对advanceSplash进行移除的操作
    [self.advanceSplash loadAd];
    NSLog(@"是否有广告返回 : %d", self.advanceSplash.isLoadAdSucceed);

}


- (UIImage*)createLogoImageFromView

{
    // 在这个方法里你可以随意 定制化logo
   // 300 170
    
    CGFloat width = self.view.frame.size.width;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 120)];
    view.backgroundColor = [UIColor blueColor];
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"app_logo"]];
    [view addSubview:imageV];
    imageV.frame = CGRectMake(0, 0, 100 * (300/170.f), 100);
    imageV.center = view.center;
    
//obtain scale
    CGFloat scale = [UIScreen mainScreen].scale;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width,
                                                      120), NO,scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //开始生成图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)showAd {
    if (self.advanceSplash.isLoadAdSucceed) {
        [self.advanceSplash showInWindow:self.view.window];
    }
}

// MARK: ======================= AdvanceSplashDelegate =======================

/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功 %s", __func__);

    [self showAd];
}

/// 广告曝光成功
- (void)advanceExposured {
    NSLog(@"广告曝光成功 %s", __func__);
    [self.bgImgV removeFromSuperview];
    self.bgImgV.image = nil;
    self.bgImgV = nil;
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    self.advanceSplash.delegate = nil;
    self.advanceSplash = nil;

}
/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);

}
/// 广告点击
- (void)advanceClicked {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)advanceDidClose {
    NSLog(@"广告关闭了 %s", __func__);
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

/// 点击了跳过
- (void)advanceSplashOnAdSkipClicked {
    NSLog(@"点击了跳过 %s", __func__);
}

// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}


- (UIImageView *)bgImgV {
    if (!_bgImgV) {
        _bgImgV = [[UIImageView alloc] init];
    }
    _bgImgV.frame = [UIScreen mainScreen].bounds;
    return _bgImgV;
}
@end
