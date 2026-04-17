//
//  AdvFunlinkNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2020/4/14.
//

#import "AdvFunlinkNativeExpressAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdWrapper.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvFunlinkNativeExpressAdapter () <FLinkNativeDelegate, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) FLinkNativeManager *flink_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdWrapper *> *nativeAdObjects;
@property (nonatomic, strong) NSArray<FLinkFeedAdData *> *feedAdArray;

@end

@implementation AdvFunlinkNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _flink_ad = [[FLinkNativeManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.adCount = 1;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
}

- (void)adapter_loadAd {
    [_flink_ad loadAdData];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    _flink_ad.showAdController = rootViewController;
    
    [self.feedAdArray enumerateObjectsUsingBlock:^(FLinkFeedAdData * _Nonnull feedAd, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
            return obj.expressView == feedAd.adView;
        }].firstObject;
        if (self.flink_ad.getCurrentBaseEcpmInfo.isAdValid) { // 有效性判断
            [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId wrapper:wrapper];
        } else {
            [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:wrapper error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
        }
    }];
}

#pragma mark: - FLinkNativeDelegate
- (void)nativeAdDidLoadDatas:(NSArray<__kindof FLinkFeedAdData *> *)datas {
    self.feedAdArray = datas;
    if (!datas.count) {
        NSError *error = [NSError errorWithDomain:@"FunlinkAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    self.nativeAdObjects = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(__kindof FLinkFeedAdData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdWrapper *object = [[AdvNativeExpressAdWrapper alloc] init];
        object.expressView = data.adView;
        object.identifier = self.adapterId;
        [self.nativeAdObjects addObject:object];
    }];
    
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
    [self.delegate nativeAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
}

- (void)nativeAdDidFailed:(NSError *)error {
    [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeAdDidVisible {
    AdvNativeExpressAdWrapper *wrapper = self.nativeAdObjects.firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)nativeAdDidClicked {
    AdvNativeExpressAdWrapper *wrapper = self.nativeAdObjects.firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)nativeAdDidCloseWithADView:(UIView *)nativeAdView {
    AdvNativeExpressAdWrapper *wrapper = self.nativeAdObjects.firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)dealloc {
    
}

@end
