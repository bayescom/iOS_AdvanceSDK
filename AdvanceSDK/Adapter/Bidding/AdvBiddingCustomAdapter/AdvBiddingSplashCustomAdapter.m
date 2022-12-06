//
//  AdvBiddingSplashCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/7/27.
//

#import "AdvBiddingSplashCustomAdapter.h"
#import "AdvBiddingSplashScapegoat.h"
#import <AdvanceSDK/AdvanceSplash.h>
//#import "ABUDCustomSplashView.h"
#import "AdvBiddingCongfig.h"
//#import "AdvSupplierModel.h"
//# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
//#import <ABUAdSDK/ABUAdSDK.h>
//#else
//#import <Ads-Mediation-CN/ABUAdSDK.h>
//#endif

@interface AdvBiddingSplashCustomAdapter ()
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
//@property (nonatomic, strong) ABUDCustomSplashView *splashView;
@property (nonatomic, strong) UIView *customBottomView;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, strong) AdvBiddingSplashScapegoat *scapegoat;

@end

@implementation AdvBiddingSplashCustomAdapter

- (AdvBiddingSplashScapegoat *)scapegoat{
    if (!_scapegoat) {
        _scapegoat = [[AdvBiddingSplashScapegoat alloc]init];
        _scapegoat.a = self;
    }
    return _scapegoat;
}

- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

- (ABUCustomAdapterVersion *)basedOnCustomAdapterVersion {
    return ABUCustomAdapterVersion1_1;
}

- (void)dismissSplashAd {
//    NSLog(@"----------->自定义开屏adapter开始释放啦啦<------------");
    self.advanceSplash = nil;
    self.customBottomView = nil;
}


- (void)initializeAdapterWithConfiguration:(ABUSdkInitConfig *_Nullable)initConfig {
//    NSLog(@"----------->自定义开屏adapter开始init啦啦 %@<------------", initConfig.appKey);

}

- (void)loadSplashAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
//    NSLog(@"----------->自定义开屏adapter开始加载啦啦<------------");
    
    
    AdvSupplierModel *model = [[AdvBiddingCongfig defaultManager] returnSupplierByAdspotId:slotID];
    
    _advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:slotID
                                                  viewController:self.bridge.viewControllerForPresentingModalView];

    [_advanceSplash performSelector:@selector(setIsGMBidding:) withObject:@(1)];

    _customBottomView = parameter[ABUAdLoadingParamSPCustomBottomView];
    
    if (_customBottomView) {
        _advanceSplash.logoImage = [self convertViewToImage:self.customBottomView];
        self.advanceSplash.showLogoRequire = YES;
    }
    _advanceSplash.delegate = self.scapegoat;
    [_advanceSplash loadAdWithSupplierModel:model];

//    [self.bridge splashAd:self didLoadWithExt:@{ABUMediaAdLoadingExtECPM:@"100000"}];

}

/// adapter的版本号
- (NSString *_Nonnull)adapterVersion {
    return @"1.0.0";
}

/// adn的版本号
- (NSString *_Nonnull)networkSdkVersion {
    return @"4.0.1.9";
}

///// 隐私权限更新，用户更新隐私配置时触发，初始化方法调用前一定会触发一次
- (void)didRequestAdPrivacyConfigUpdate:(NSDictionary *)config {

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

- (void)showSplashAdInWindow:(nonnull UIWindow *)window parameter:(nonnull NSDictionary *)parameter {

//    NSLog(@"----------->自定义开屏adapter开始展示啦啦<------------");

//    [self.splashView showInWindow:window];
//    if (self.customBottomView) {
//        [window addSubview:self.customBottomView];
//    }
    [_advanceSplash performSelector:@selector(gmShowAd)];
//    [self.advanceSplash showAd];
    // 模拟广告展示回调
}


- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
//    NSLog(@"----------->自定义开屏adapter有结果啦啦 %d %ld %@ %@ %@ %@<------------", result.win, result.winnerPrice, result.lossDescription, result.winnerAdnID, result.ext, result.originNativeAdData);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    if (_scapegoat) {
        _scapegoat = nil;
    }
    if (_advanceSplash){
        _advanceSplash.delegate = nil;
        _advanceSplash = nil;
    }
    if (_customBottomView) {
        [_customBottomView removeFromSuperview];
        _customBottomView = nil;
    }
}

@end
