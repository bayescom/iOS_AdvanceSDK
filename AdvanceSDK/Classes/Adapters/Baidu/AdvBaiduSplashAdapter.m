//
//  AdvBaiduSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import "AdvBaiduSplashAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvBaiduSplashAdapter ()<BaiduMobAdSplashDelegate, AdvanceSplashCommonAdapter>

@property (nonatomic, strong) BaiduMobAdSplash *bd_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvBaiduSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
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
}

- (void)adapter_loadAd {
    [self.bd_ad load];
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
    [self.bd_ad showInContainerView:window];
}

#pragma mark: -BaiduMobAdSplashDelegate
- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash {
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:[[splash getECPMLevel] integerValue]];
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:[[splash getECPMLevel] integerValue]];
}

- (void)splashAdLoadFailCode:(NSString *)errCode
                     message:(NSString *)message
                    splashAd:(BaiduMobAdSplash *)nativeAd {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)splashDidExposure:(BaiduMobAdSplash *)splash {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    [self baiduAdDidClose];
}

- (void)baiduAdDidClose {
    [_bottomLogoView removeFromSuperview];
    [_bd_ad stop];
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
