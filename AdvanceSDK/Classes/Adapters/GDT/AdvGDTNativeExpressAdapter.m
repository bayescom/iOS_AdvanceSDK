//
//  AdvGDTNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTNativeExpressAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdObject.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvGDTNativeExpressAdapter () <GDTNativeExpressAdDelegete, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) GDTNativeExpressAd *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdObject *> *nativeAdObjects;

@end

@implementation AdvGDTNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _gdt_ad = [[GDTNativeExpressAd alloc] initWithPlacementId:placementId
                                                       adSize:[config[kAdvanceAdSizeKey] CGSizeValue]];
    _gdt_ad.videoMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _gdt_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_gdt_ad loadAd:1];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    [self.nativeAdObjects enumerateObjectsUsingBlock:^(__kindof AdvNativeExpressAdObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj.expressView;
        expressView.controller = rootViewController;
        if (expressView.isAdValid) { // 有效性判断
            [expressView render];
        } else {
            [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId object:obj error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
        }
    }];
}


#pragma mark: - GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (!views.count) {
        NSError *error = [NSError errorWithDomain:@"GDTAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }

    self.nativeAdObjects = [NSMutableArray array];
    [views enumerateObjectsUsingBlock:^(__kindof GDTNativeExpressAdView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdObject *object = [[AdvNativeExpressAdObject alloc] init];
        object.expressView = view;
        object.identifier = self.adapterId;
        [self.nativeAdObjects addObject:object];
    }];
    
    [self.delegate nativeAdapter_didLoadAdWithAdapterId:self.adapterId price:views.firstObject.eCPM];
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId object:object];
}

- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId object:object error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId object:object];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId object:object];
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvNativeExpressAdObject *object = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdObject *obj) {
        return obj.expressView == nativeExpressAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId object:object];
}

- (void)dealloc {
    
}

@end
