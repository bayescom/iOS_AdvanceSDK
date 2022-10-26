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
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10002619"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10006483"},
        
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"101959-10006038"},

//
    ];
    self.btn1Title = @"加载并显示广告";
}
//#define kBY_AdMediaId @"101959"
//#define kBY_Ad_Splash_Id @"10006038"
//#define kBY_Ad_Instrument_HomePage_Bottom_Banner_Id @"10006037"
//#define kBY_Ad_Instrument_HomePage_Top_Express_Id @"10006024"
//#define kBY_Ad_Instrument_EditResultPage_Express_Id @"10006023"
//#define kBY_Ad_User_HomePage_Express_Id @"10006022"

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                  viewController:self];

    self.advanceSplash.isUploadSDKVersion = YES;
    self.advanceSplash.delegate = self;
    self.advanceSplash.showLogoRequire = YES;
    self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    self.advanceSplash.timeout = 5; // 如果使用bidding 功能 timeout时长必须要比 服务器下发的bidding等待时间要长 否则会严重影响变现效率
    [self.advanceSplash loadAd];
    

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

    // 获取控制摇一摇 的单例
    id manager = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"MercuryMotionManager"), @selector(sharedManager));
    // 调用停止摇一摇
    ((void(*)(id, SEL))objc_msgSend)(manager, @selector(stopMotion));

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


//- (void)advanceBiddingAction {
//    NSLog(@"%s 开始bidding",__func__);
//}
//
//- (void)advanceBiddingEnd {
//    NSLog(@"%s 结束bidding",__func__);
//}
@end
