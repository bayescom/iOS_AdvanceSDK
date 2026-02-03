//
//  AdvSigmobRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "AdvSigmobRenderFeedAdapter.h"
#import <WindSDK/WindSDK.h>
#import <MercurySDK/MercurySDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvSigmobRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvSigmobRenderFeedAdapter () <WindNativeAdsManagerDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) WindNativeAdsManager *sigmob_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL hasFailed;

@end

@implementation AdvSigmobRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    _sigmob_ad = [[WindNativeAdsManager alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_sigmob_ad loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}


#pragma mark: - WindNativeAdsManagerDelegate
/// 广告加载成功回调
- (void)nativeAdsManagerSuccessToLoad:(WindNativeAdsManager *)adsManager
                            nativeAds:(NSArray<WindNativeAd *> *)nativeAdDataArray {
    
    WindNativeAd *nativeAd = nativeAdDataArray.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    AdvSigmobRenderFeedAdView *sigmobFeedAdView = [[AdvSigmobRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adapterId:self.adapterId viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:sigmobFeedAdView feedAdElement:element];
    
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:adsManager.getEcpm.integerValue];
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:adsManager.getEcpm.integerValue];
}

/// 广告加载出错回调
- (void)nativeAdsManager:(WindNativeAdsManager *)adsManager
        didFailWithError:(NSError *)error {
    if (!_hasFailed) { /// 某些错误码时，会重复进入此回调导致接口频繁上报线程崩溃
        _hasFailed = YES;
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:nil];
    }
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithNativeAd:(WindNativeAd *)nativeAd {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = nativeAd.title;
    element.desc = nativeAd.desc;
    element.iconUrl = nativeAd.iconUrl;
    element.imageUrlList = nativeAd.imageUrlList;
    element.mediaWidth = [[self splitImageSizeString:nativeAd.imageSizeList.firstObject].firstObject integerValue];
    element.mediaHeight = [[self splitImageSizeString:nativeAd.imageSizeList.firstObject].lastObject integerValue];
    element.buttonText = nativeAd.callToAction;
    element.isVideoAd = [self isVideoAd:nativeAd];
    if (element.isVideoAd) {
        element.mediaWidth = nativeAd.videoWidth;
        element.mediaHeight = nativeAd.videoHeight;
    }
    element.appRating = nativeAd.rating;
    element.isAdValid = YES;
    return element;
}

- (BOOL)isVideoAd:(WindNativeAd *)nativeAd {
    switch (nativeAd.feedADMode) {
        case WindFeedADModeVideo:
        case WindFeedADModeVideoPortrait:
        case WindFeedADModeVideoLandSpace:
            return YES;
        default:
            return NO;
    }
}

/// 解析字符串 " {100, 200} "
- (NSArray *)splitImageSizeString:(NSString *)sizeString {
    // 去掉大括号
    NSString *cleanedString = [sizeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    // 使用逗号分隔字符串
    NSArray *components = [cleanedString componentsSeparatedByString:@","];
    // 转换为数字
    if (components.count == 2) {
        NSString *firstString = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *secondString = [components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return @[firstString, secondString];
    }
    return @[];
}

- (void)dealloc {

}

@end
