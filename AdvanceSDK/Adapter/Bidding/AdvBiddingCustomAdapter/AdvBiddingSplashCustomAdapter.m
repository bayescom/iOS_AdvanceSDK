//
//  AdvBiddingSplashCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/7/27.
//

#import "AdvBiddingSplashCustomAdapter.h"
#import <AdvanceSDK/AdvanceSplash.h>
//#import "ABUDCustomSplashView.h"
#import "AdvBiddingCongfig.h"
#import "AdvSupplierModel.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

@interface AdvBiddingSplashCustomAdapter ()<AdvanceSplashDelegate, ABUCustomSplashAdapter>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
//@property (nonatomic, strong) ABUDCustomSplashView *splashView;
@property (nonatomic, strong) UIView *customBottomView;

@end

@implementation AdvBiddingSplashCustomAdapter
- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

- (void)dismissSplashAd {
//    NSLog(@"----------->自定义开屏adapter开始释放啦啦<------------");
    self.advanceSplash = nil;
    self.customBottomView = nil;
}

- (void)loadSplashAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
//    NSLog(@"----------->自定义开屏adapter开始加载啦啦<------------");
    
    
    AdvSupplierModel *model = [[AdvBiddingCongfig defaultManager] returnSupplierByAdspotId:slotID];
    
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:slotID
                                                  viewController:self.bridge.viewControllerForPresentingModalView];

    [self.advanceSplash performSelector:@selector(setIsGMBidding:) withObject:@(1)];

    self.customBottomView = parameter[ABUAdLoadingParamSPCustomBottomView];
    
    if (self.customBottomView) {
        self.advanceSplash.logoImage = [self convertViewToImage:self.customBottomView];
        self.advanceSplash.showLogoRequire = YES;
    }
    self.advanceSplash.delegate = self;
    [self.advanceSplash loadAdWithSupplierModel:model];

//    [self.bridge splashAd:self didLoadWithExt:@{ABUMediaAdLoadingExtECPM:@"100000"}];

}

- (UIImage *)convertViewToImage:(UIView *)view {
    
    UIImage *imageRet = [[UIImage alloc]init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageRet;
    
}

- (void)advanceBiddingEndWithPrice:(NSInteger)price {
    NSLog(@"%s %ld", __func__, price);
    [self.bridge splashAd:self didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", price]}];
}

- (void)showSplashAdInWindow:(nonnull UIWindow *)window parameter:(nonnull NSDictionary *)parameter {

//    NSLog(@"----------->自定义开屏adapter开始展示啦啦<------------");

//    [self.splashView showInWindow:window];
//    if (self.customBottomView) {
//        [window addSubview:self.customBottomView];
//    }
    [self.advanceSplash performSelector:@selector(gmShowAd)];
//    [self.advanceSplash showAd];
    // 模拟广告展示回调
}

/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
//    NSLog(@"广告数据拉取成功 %s", __func__);
}

/// 广告曝光成功
- (void)advanceExposured {
//    NSLog(@"广告曝光成功 %s", __func__);
//    [self.bridge splashAdWillVisible:self];
    [self.bridge splashAdWillVisible:self];
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
//    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

}

/// 广告点击
- (void)advanceClicked {
//    NSLog(@"广告点击 %s", __func__);
    [self.bridge splashAdDidClick:self];
}

/// 广告关闭
- (void)advanceDidClose {
//    NSLog(@"广告关闭了 %s", __func__);
    [self.bridge splashAdDidClose:self];
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
//    NSLog(@"广告倒计时结束 %s", __func__);
    [self.bridge splashAdDidCountDownToZero:self];
}

/// 点击了跳过
- (void)advanceSplashOnAdSkipClicked {
//    NSLog(@"点击了跳过 %s", __func__);
    [self.bridge splashAdDidClickSkip:self];
//    [self.bridge splashAdDidClose:self];
}

// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
//    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}




- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
//    NSLog(@"----------->自定义开屏adapter有结果啦啦 %d %ld %@ %@ %@ %@<------------", result.win, result.winnerPrice, result.lossDescription, result.winnerAdnID, result.ext, result.originNativeAdData);
}


@end