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

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     - 超时时间只需要设置AdvanceSplash的 timeout属性, 如果在timeout时间内没有广告曝光, 则会强制移除开屏广告,并触发错误回调

     - 每次加载需开屏广告需使用最新的实例, 不要进行本地存储, 或计时器持有的操作

     - 保证在开屏广告生命周期内(包括请求,曝光成功后的展现时间内),不要更换rootVC, 也不要对Window进行操作

     */
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10002619"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10006483"},
        
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"101959-10006038"},

//
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    
    if (self.advanceSplash) {
        self.advanceSplash.delegate = nil;
        self.advanceSplash = nil;
    }
    
    // 每次加载广告请 使用新的实例  不要用懒加载, 不要对广告对象进行本地化存储相关的操作
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                  viewController:self];

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

    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    self.advanceSplash.timeout = 5; // 如果使用bidding 功能 timeout时长必须要比 服务器下发的bidding等待时间要长 否则会严重影响变现效率
    [self.advanceSplash loadAd];
    

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

// MARK: ======================= AdvanceSplashDelegate =======================

/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功 %s", __func__);
//    [self loadAdBtn1Action];

}

/// 广告曝光成功
- (void)advanceExposured {
    NSLog(@"广告曝光成功 %s", __func__);
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

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

//    // 获取控制摇一摇 的单例
//    id manager = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"MercuryMotionManager"), @selector(sharedManager));
//    // 调用停止摇一摇
//    ((void(*)(id, SEL))objc_msgSend)(manager, @selector(stopMotion));

}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
    NSLog(@"广告倒计时结束 %s", __func__);
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
@end
