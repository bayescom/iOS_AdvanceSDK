//
//  AdvCSJNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJNativeExpressAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdObject.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvCSJNativeExpressAdapter () <BUNativeExpressAdViewDelegate, BUCustomEventProtocol, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) BUNativeExpressAdManager *csj_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdObject *> *nativeAdObjects;

@end

@implementation AdvCSJNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = placementId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionFeed;
    slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
    _csj_ad = [[BUNativeExpressAdManager alloc] initWithSlot:slot adSize:[config[kAdvanceAdSizeKey] CGSizeValue]];
    _csj_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_csj_ad loadAdDataWithCount:1];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    [self.nativeAdObjects enumerateObjectsUsingBlock:^(__kindof AdvNativeExpressAdObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj.expressView;
        expressView.rootViewController = rootViewController;
        [expressView render];
    }];
}


#pragma mark: - BUNativeExpressAdViewDelegate
- (void)nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(nonnull NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (!views.count) {
        NSError *error = [NSError errorWithDomain:@"BUAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    self.nativeAdObjects = [NSMutableArray array];
    [views enumerateObjectsUsingBlock:^(__kindof BUNativeExpressAdView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdObject *object = [[AdvNativeExpressAdObject alloc] init];
        object.expressView = view;
        object.identifier = self.adapterId;
        [self.nativeAdObjects addObject:object];
    }];
    
    NSDictionary *ext = views.firstObject.mediaExt;
    [self.delegate nativeAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId object:object];
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId object:object error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId object:object];
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId object:object];
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId object:object];
}

- (void)dealloc {
    
}

@end
