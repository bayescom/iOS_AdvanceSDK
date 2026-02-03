//
//  AdvMercuryNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryNativeExpressAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdWrapper.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvMercuryNativeExpressAdapter () <MercuryNativeExpressAdDelegete, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) MercuryNativeExpressAd *mercury_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdWrapper *> *nativeAdObjects;

@end

@implementation AdvMercuryNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _mercury_ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:placementId];
    _mercury_ad.renderSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    _mercury_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_mercury_ad loadAdWithCount:1];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    [self.nativeAdObjects enumerateObjectsUsingBlock:^(__kindof AdvNativeExpressAdWrapper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MercuryNativeExpressAdView *expressView = (MercuryNativeExpressAdView *)obj.expressView;
        expressView.controller = rootViewController;
        if (expressView.isAdValid) { // 有效性判断
            [expressView render];
        } else {
            [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:obj error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
        }
    }];
}

#pragma mark: - MercuryNativeExpressAdDelegete
/// 拉取原生模板广告成功
- (void)mercury_nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views {
    if (!views.count) {
        NSError *error = [NSError errorWithDomain:@"MercuryAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    self.nativeAdObjects = [NSMutableArray array];
    [views enumerateObjectsUsingBlock:^(__kindof MercuryNativeExpressAdView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdWrapper *object = [[AdvNativeExpressAdWrapper alloc] init];
        object.expressView = view;
        object.identifier = self.adapterId;
        [self.nativeAdObjects addObject:object];
    }];
    
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:views.firstObject.price];
    [self.delegate nativeAdapter_didLoadAdWithAdapterId:self.adapterId price:views.firstObject.price];
}

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoad:(MercuryNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId wrapper:wrapper];
}

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:wrapper error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId wrapper:wrapper];
}

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId wrapper:wrapper];
}

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)dealloc {
    
}

@end
