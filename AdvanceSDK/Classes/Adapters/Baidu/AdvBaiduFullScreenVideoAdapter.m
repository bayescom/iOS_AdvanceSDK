//
//  AdvBaiduFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//

#import "AdvBaiduFullScreenVideoAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceFullScreenVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvBaiduFullScreenVideoAdapter ()<BaiduMobAdExpressFullScreenVideoDelegate, AdvanceFullScreenVideoCommonAdapter>
@property (nonatomic, strong) BaiduMobAdExpressFullScreenVideo *bd_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvBaiduFullScreenVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bd_ad = [[BaiduMobAdExpressFullScreenVideo alloc] init];
    _bd_ad.delegate = self;
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.adType = BaiduMobAdTypeFullScreenVideo;
}

- (void)adapter_loadAd {
    [_bd_ad load];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_bd_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

#pragma mark - BaiduMobAdExpressFullScreenVideoDelegate
- (void)fullScreenVideoAdLoadSuccess:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.delegate fullscreenAdapter_didLoadAdWithAdapterId:self.adapterId price:[[video getECPMLevel] integerValue]];
}

- (void)fullScreenVideoAdLoadFailCode:(NSString *)errCode message:(NSString *)message fullScreenAd:(BaiduMobAdExpressFullScreenVideo *)video {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.delegate fullscreenAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)fullScreenVideoAdShowFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.delegate fullscreenAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)fullScreenVideoAdDidStarted:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.delegate fullscreenAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)fullScreenVideoAdDidClick:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.delegate fullscreenAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)fullScreenVideoAdDidClose:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.delegate fullscreenAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)fullScreenVideoAdDidPlayFinish:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.delegate fullscreenAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

@end
