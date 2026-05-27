//
//  AdvBaiduFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//

#import "AdvBaiduFullScreenVideoAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvBaiduFullScreenVideoAdapter ()<BaiduMobAdExpressFullScreenVideoDelegate, AdvanceCommonFullscreenVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonFullscreenVideoAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdExpressFullScreenVideo *bd_ad;

@end

@implementation AdvBaiduFullScreenVideoAdapter

- (void)adapter_setFullscreenBridge:(id<AdvanceCommonFullscreenVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bd_ad = [[BaiduMobAdExpressFullScreenVideo alloc] init];
    _bd_ad.delegate = self;
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.adType = BaiduMobAdTypeFullScreenVideo;
    [_bd_ad load];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_bd_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_bd_ad biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:nil];
    } else {
        [_bd_ad biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:nil];
    }
}

#pragma mark - BaiduMobAdExpressFullScreenVideoDelegate
- (void)fullScreenVideoAdLoadSuccess:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.bridge fullscreen_didLoadAdWithAdapter:self price:[[video getECPMLevel] integerValue]];
}

- (void)fullScreenVideoAdLoadFailCode:(NSString *)errCode message:(NSString *)message fullScreenAd:(BaiduMobAdExpressFullScreenVideo *)video {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge fullscreen_failedToLoadAdWithAdapter:self error:error];
}

- (void)fullScreenVideoAdShowFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.bridge fullscreen_failedToShowAdWithAdapter:self error:error];
}

- (void)fullScreenVideoAdDidStarted:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.bridge fullscreen_didAdExposuredWithAdapter:self];
}

- (void)fullScreenVideoAdDidClick:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.bridge fullscreen_didAdClickedWithAdapter:self];
}

- (void)fullScreenVideoAdDidClose:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.bridge fullscreen_didAdClosedWithAdapter:self];
}

- (void)fullScreenVideoAdDidPlayFinish:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.bridge fullscreen_didAdPlayFinishWithAdapter:self];
}

@end
