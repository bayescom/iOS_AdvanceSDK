//
//  AdvBiddingSplashCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/7/27.
//

#import "AdvBiddingSplashCustomAdapter.h"
#import <AdvanceSDK/AdvanceSplash.h>
#import "ABUDCustomSplashView.h"

@interface AdvBiddingSplashCustomAdapter ()<AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@property (nonatomic, strong) ABUDCustomSplashView *splashView;
@property (nonatomic, strong) UIView *customBottomView;

@end

@implementation AdvBiddingSplashCustomAdapter
- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

- (void)dismissSplashAd {
    NSLog(@"----------->自定义开屏adapter开始释放啦啦<------------");
    self.advanceSplash = nil;
}

- (void)loadSplashAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
    NSLog(@"----------->自定义开屏adapter开始加载啦啦<------------");
    CGSize size = [parameter[ABUAdLoadingParamSPExpectSize] CGSizeValue];
    self.customBottomView = parameter[ABUAdLoadingParamSPCustomBottomView];
    
    self.splashView = [ABUDCustomSplashView splashViewWithSize:size rootViewController:self.bridge.viewControllerForPresentingModalView];
    __weak typeof(self) ws = self;
    // 模拟点击事件
    self.splashView.didClickAction = ^(ABUDCustomSplashView * _Nonnull view) {
        __strong typeof(ws) self = ws;
        [self.bridge splashAdDidClick:self];
    };
    // 模拟关闭事件
    self.splashView.dismissCallback = ^(ABUDCustomSplashView * _Nonnull view, BOOL skip) {
        __strong typeof(ws) self = ws;
        if (skip) {
            [self.bridge splashAdDidClickSkip:self];
        } else {
            [self.bridge splashAdDidCountDownToZero:self];
        }
        [self.bridge splashAdDidClose:self];
    };
    // 模拟加载完成
    [self.bridge splashAd:self didLoadWithExt:@{ABUMediaAdLoadingExtECPM:@"100000"}];

}

- (void)showSplashAdInWindow:(nonnull UIWindow *)window parameter:(nonnull NSDictionary *)parameter {

    NSLog(@"----------->自定义开屏adapter开始展示啦啦<------------");

    [self.splashView showInWindow:window];
    if (self.customBottomView) {
        [window addSubview:self.customBottomView];
    }
    // 模拟广告展示回调
    [self.bridge splashAdWillVisible:self];
}


- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
    NSLog(@"----------->自定义开屏adapter有结果啦啦 %d %ld %@ %@ %@ %@<------------", result.win, result.winnerPrice, result.lossDescription, result.winnerAdnID, result.ext, result.originNativeAdData);
}


@end
