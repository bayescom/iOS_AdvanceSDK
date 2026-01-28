//
//  AdvKSNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSNativeExpressAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdWrapper.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvKSNativeExpressAdapter ()<KSFeedAdsManagerDelegate, KSFeedAdDelegate, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) KSFeedAdsManager *ks_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdWrapper *> *nativeAdObjects;
@property (nonatomic, strong) NSArray<KSFeedAd *> *feedAdArray;

@end

@implementation AdvKSNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _ks_ad = [[KSFeedAdsManager alloc] initWithPosId:placementId size:[config[kAdvanceAdSizeKey] CGSizeValue]];
    _ks_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_ks_ad loadAdDataWithCount:1];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    [self.feedAdArray enumerateObjectsUsingBlock:^(KSFeedAd * _Nonnull feedAd, NSUInteger idx, BOOL * _Nonnull stop) {
        feedAd.delegate = self;
        
        AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
            return obj.expressView == feedAd.feedView;
        }].firstObject;
        if (feedAd.materialReady) { // 有效性判断
            [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId wrapper:wrapper];
        } else {
            [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:wrapper error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
        }
    }];
}

#pragma mark: - KSFeedAdsManagerDelegate, KSFeedAdDelegate
- (void)feedAdsManagerSuccessToLoad:(KSFeedAdsManager *)adsManager nativeAds:(NSArray<KSFeedAd *> *_Nullable)feedAdDataArray {
    self.feedAdArray = feedAdDataArray;
    if (!feedAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"KSADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    self.nativeAdObjects = [NSMutableArray array];
    [feedAdDataArray enumerateObjectsUsingBlock:^(__kindof KSFeedAd * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdWrapper *object = [[AdvNativeExpressAdWrapper alloc] init];
        object.expressView = obj.feedView;
        object.identifier = self.adapterId;
        [self.nativeAdObjects addObject:object];
    }];
    
    [self.delegate nativeAdapter_didLoadAdWithAdapterId:self.adapterId price:feedAdDataArray.firstObject.ecpm];
}

- (void)feedAdsManager:(KSFeedAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)feedAdDidShow:(KSFeedAd *)feedAd {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == feedAd.feedView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)feedAdDidClick:(KSFeedAd *)feedAd {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == feedAd.feedView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)feedAdDislike:(KSFeedAd *)feedAd {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == feedAd.feedView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)dealloc {
    
}

@end
