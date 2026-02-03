//
//  AdvTanxNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxNativeExpressAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdWrapper.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvTanxNativeExpressAdapter () <TXAdFeedManagerDelegate, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) TXAdFeedManager *tanx_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdWrapper *> *nativeAdObjects;
@property (nonatomic, strong) NSArray *adModels;
@property (nonatomic, assign) CGSize adSize;

@end

@implementation AdvTanxNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    self.adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    TXAdFeedSlotModel *slotModel = [[TXAdFeedSlotModel alloc] init];
    slotModel.pid = placementId;
    slotModel.showAdFeedBackView = NO;
    _tanx_ad = [[TXAdFeedManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
}

- (void)adapter_loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeTemplate adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        } else { // 获取广告成功
            strongSelf.adModels = viewModelArray;
            TXAdModel *adModel = viewModelArray.firstObject;
            NSInteger ecpm = adModel.bid.bidPrice.integerValue;
            
            strongSelf.nativeAdObjects = [NSMutableArray array];
            [viewModelArray enumerateObjectsUsingBlock:^(__kindof TXAdModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                AdvNativeExpressAdWrapper *object = [[AdvNativeExpressAdWrapper alloc] init];
                object.tanxAdModel = model;
                object.identifier = strongSelf.adapterId;
                [strongSelf.nativeAdObjects addObject:object];
            }];
            
            [strongSelf.delegate adapter_cacheAdapterIfNeeded:strongSelf adapterId:strongSelf.adapterId price:ecpm];
            [strongSelf.delegate nativeAdapter_didLoadAdWithAdapterId:strongSelf.adapterId price:ecpm];
        }
    }];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    TXAdFeedTemplateConfig *config = [[TXAdFeedTemplateConfig alloc] init];
    config.templateWidth = self.adSize.width - 2 * 15.0;
    NSError *error;
    NSArray<TXAdFeedModule *> *feedModules = [self.tanx_ad renderFeedTemplateWithModel:self.adModels config:config error:&error];
    
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.tanxAdModel == self.adModels.firstObject;
    }].firstObject;
    if (!error) { /// render success
        if (wrapper) {
            wrapper.expressView = feedModules.firstObject.view;
            [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId wrapper:wrapper];
        }
    } else { /// render fail
        [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:wrapper error:error];
    }
}


#pragma mark: - TXAdFeedManagerDelegate
/// ❌❌ 当feedModules获取为空时，还是会进入渲染成功回调
- (void)onAdRenderSuccess:(TXAdModel *)model {
    
}

- (void)onAdExposing:(TXAdModel *)model {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.tanxAdModel == model;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId wrapper:wrapper];
}

/// 广告点击
- (void)onAdClick:(TXAdModel *)model {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.tanxAdModel == model;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId wrapper:wrapper];
}

/// 广告滑动跳转
- (void)onAdSliding:(TXAdModel *)model {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.tanxAdModel == model;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)onAdClose:(TXAdModel *)model {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.tanxAdModel == model;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)dealloc {
    
}

@end
