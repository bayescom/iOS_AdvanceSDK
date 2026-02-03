//
//  AdvGDTBannerAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTBannerAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceBannerCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvGDTBannerAdapter () <GDTUnifiedBannerViewDelegate, AdvanceBannerCommonAdapter>
@property (nonatomic, strong) GDTUnifiedBannerView *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvGDTBannerAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _gdt_ad = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:placementId viewController:config[kAdvanceAdPresentControllerKey]];
    _gdt_ad.animated = NO;
    _gdt_ad.autoSwitchInterval = 0; // 暂不支持刷新
    _gdt_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_gdt_ad loadAdAndShow];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _gdt_ad.isAdValid;
    if (!valid) {
        [self.delegate bannerAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

- (id)adapter_bannerView {
    return self.bannerView;
}


#pragma mark: - GDTUnifiedBannerViewDelegate
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    self.bannerView = unifiedBannerView;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:unifiedBannerView.eCPM];
    [self.delegate bannerAdapter_didLoadAdWithAdapterId:self.adapterId price:unifiedBannerView.eCPM];
}

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
    [self.delegate bannerAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.delegate bannerAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.delegate bannerAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView {
    [_gdt_ad removeFromSuperview];
    _gdt_ad = nil;
    [self.delegate bannerAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
