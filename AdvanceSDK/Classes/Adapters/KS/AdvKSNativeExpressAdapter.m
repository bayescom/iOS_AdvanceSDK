//
//  AdvKSNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSNativeExpressAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdObject.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvKSNativeExpressAdapter ()<KSFeedAdsManagerDelegate, KSFeedAdDelegate, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) KSFeedAdsManager *ks_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdObject *> *nativeAdObjects;
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
        
        AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
            return obj.expressView == feedAd.feedView;
        }].firstObject;
        if (feedAd.materialReady) { // 有效性判断
            [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId object:object];
        } else {
            [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId object:object error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
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
        AdvNativeExpressAdObject *object = [[AdvNativeExpressAdObject alloc] init];
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
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == feedAd.feedView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId object:object];
}

- (void)feedAdDidClick:(KSFeedAd *)feedAd {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == feedAd.feedView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId object:object];
}

- (void)feedAdDislike:(KSFeedAd *)feedAd {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == feedAd.feedView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId object:object];
}

- (void)dealloc {
    
}

@end
