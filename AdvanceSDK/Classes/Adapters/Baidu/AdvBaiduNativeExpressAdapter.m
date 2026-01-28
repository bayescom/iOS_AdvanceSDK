//
//  AdvBaiduNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "AdvBaiduNativeExpressAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceNativeExpressCommonAdapter.h"
#import "AdvNativeExpressAdWrapper.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "NSArray+Adv.h"

@interface AdvBaiduNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) NSMutableArray<AdvNativeExpressAdWrapper *> *nativeAdObjects;
@property (nonatomic, assign) CGSize adSize;

@end

@implementation AdvBaiduNativeExpressAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    self.adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    _bd_ad = [[BaiduMobAdNative alloc] init];
    _bd_ad.adDelegate = self;
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.baiduMobAdsWidth = @(self.adSize.width);
    _bd_ad.baiduMobAdsHeight = @(self.adSize.height);
    _bd_ad.presentAdViewController = config[kAdvanceAdPresentControllerKey];
    _bd_ad.isExpressNativeAds = YES;
}

- (void)adapter_loadAd {
    [_bd_ad load];
}

- (void)adapter_render:(UIViewController *)rootViewController {
    [self.nativeAdObjects enumerateObjectsUsingBlock:^(__kindof AdvNativeExpressAdWrapper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BaiduMobAdExpressNativeView *expressView = (BaiduMobAdExpressNativeView *)obj.expressView;
        expressView.interationDelegate = self;
        expressView.baseViewController = rootViewController;
        
        if (expressView.style_type == FeedType_PORTRAIT_VIDEO) {
            expressView.width = self.adSize.width * 0.8;
        }
        // 展示前检查是否过期，2h后广告将过期
        if (![expressView isExpired]) {
            [expressView render];
        } else {
            [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:obj error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
        }
    }];
}


#pragma mark: - BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    self.nativeAdObjects = [NSMutableArray array];
    [nativeAds enumerateObjectsUsingBlock:^(__kindof BaiduMobAdExpressNativeView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        AdvNativeExpressAdWrapper *object = [[AdvNativeExpressAdWrapper alloc] init];
        object.expressView = view;
        object.identifier = self.adapterId;
        [self.nativeAdObjects addObject:object];
    }];
    
    [self.delegate nativeAdapter_didLoadAdWithAdapterId:self.adapterId price:[[nativeAds.firstObject getECPMLevel] integerValue]];
}

- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.delegate nativeAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeAdExpressSuccessRender:(BaiduMobAdExpressNativeView *)express nativeAd:(BaiduMobAdNative *)nativeAd {
    express.frame = ({
        CGRect frame = express.frame;
        frame.origin.x = (self.adSize.width - express.frame.size.width) / 2;
        frame;
    });
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == express;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderSuccessWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdExposuredWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdRenderFailWithAdapterId:self.adapterId wrapper:wrapper error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == nativeAdView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClickedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
    AdvNativeExpressAdWrapper *wrapper = [self.nativeAdObjects adv_filter:^BOOL(AdvNativeExpressAdWrapper *obj) {
        return obj.expressView == adView;
    }].firstObject;
    [self.delegate nativeAdapter_didAdClosedWithAdapterId:self.adapterId wrapper:wrapper];
}

- (void)dealloc {
    
}

@end
