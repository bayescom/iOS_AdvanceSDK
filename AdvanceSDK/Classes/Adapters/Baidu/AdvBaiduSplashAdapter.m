//
//  AdvBaiduSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import "AdvBaiduSplashAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvBaiduSplashAdapter ()<BaiduMobAdSplashDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdSplash *bd_ad;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvBaiduSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    _bd_ad = [[BaiduMobAdSplash alloc] init];
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.delegate = self;
    _bd_ad.presentAdViewController =  config[kAdvanceAdPresentControllerKey];
    _bd_ad.timeout = timeout * 1.0 / 1000.0;
    
    CGRect adFrame = [UIScreen mainScreen].bounds;
    if (_bottomLogoView) {
        adFrame.size.height -= _bottomLogoView.bounds.size.height;
    }
    _bd_ad.adSize = adFrame.size;
    [_bd_ad load];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    // 设置logo
    if (_bottomLogoView) {
        _bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _bottomLogoView.bounds.size.height);
        [window addSubview:_bottomLogoView];
    }
    [_bd_ad showInContainerView:window];
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_bd_ad biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:nil];
    } else {
        [_bd_ad biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:nil];
    }
}

#pragma mark: -BaiduMobAdSplashDelegate
- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash {
    [self.bridge splash_didLoadAdWithAdapter:self price:[[splash getECPMLevel] integerValue]];
}

- (void)splashAdLoadFailCode:(NSString *)errCode
                     message:(NSString *)message
                    splashAd:(BaiduMobAdSplash *)nativeAd {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.bridge splash_failedToShowAdWithAdapter:self error:error];
}

- (void)splashDidExposure:(BaiduMobAdSplash *)splash {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    [self baiduAdDidClose];
}

- (void)baiduAdDidClose {
    [_bottomLogoView removeFromSuperview];
    [_bd_ad stop];
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
