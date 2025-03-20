//
//  KsFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "KsFullScreenVideoAdapter.h"
#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
#import "KSAdSDK.h"
#endif

#import "AdvanceFullScreenVideo.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface KsFullScreenVideoAdapter ()<KSFullscreenVideoAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) KSFullscreenVideoAd *ks_ad;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation KsFullScreenVideoAdapter

@synthesize isWinnerAdapter = _isWinnerAdapter;
@synthesize isVideoCached = _isVideoCached;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _ks_ad = [[KSFullscreenVideoAd alloc] initWithPosId:_supplier.adspotid];
        _ks_ad.showDirection = KSAdShowDirection_Vertical;
        _ks_ad.shouldMuted = _adspot.muted;
        _ks_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_ks_ad loadAdData];
}

- (void)showAd {
    [_ks_ad showAdFromRootViewController:self.adspot.viewController];
}

- (void)winnerAdapterToShowAd {
    _isWinnerAdapter = YES;
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingFullscreenVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingFullscreenVideoADWithSpotId:self.adspot.adspotid];
    }
    if (_isVideoCached && [self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (BOOL)isAdValid {
    return _ks_ad.isValid;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

/**
 This method is called when video ad material loaded successfully.
 */
- (void)fullscreenVideoAdDidLoad:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot.manager setECPMIfNeeded:fullscreenVideoAd.ecpm supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];

}
/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)fullscreenVideoAd:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

/**
 This method is called when cached successfully.
 */
- (void)fullscreenVideoAdVideoDidLoad:(KSFullscreenVideoAd *)fullscreenVideoAd {
    _isVideoCached = YES;
    /// 竞胜方才进行缓存成功回调
    if (_isWinnerAdapter && [self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}
/**
 This method is called when video ad slot will be showing.
 */
- (void)fullscreenVideoAdWillVisible:(KSFullscreenVideoAd *)fullscreenVideoAd {
    
}
/**
 This method is called when video ad slot has been shown.
 */
- (void)fullscreenVideoAdDidVisible:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
}
/**
 This method is called when video ad is about to close.
 */
- (void)fullscreenVideoAdWillClose:(KSFullscreenVideoAd *)fullscreenVideoAd {
    
}
/**
 This method is called when video ad is closed.
 */
- (void)fullscreenVideoAdDidClose:(KSFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidCloseForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 This method is called when video ad is clicked.
 */
- (void)fullscreenVideoAdDidClick:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidClickForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}
/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)fullscreenVideoAdDidPlayFinish:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidEndPlayingForSpotId:extra:)]) {
            [self.delegate fullscreenVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}
/**
 This method is called when the video begin to play.
 */
- (void)fullscreenVideoAdStartPlay:(KSFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}
/**
 This method is called when the user clicked skip button.
 */
- (void)fullscreenVideoAdDidClickSkip:(KSFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidClickSkipForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidClickSkipForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
