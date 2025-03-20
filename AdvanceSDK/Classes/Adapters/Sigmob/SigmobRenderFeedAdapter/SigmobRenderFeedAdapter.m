//
//  SigmobRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "SigmobRenderFeedAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "SigmobRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface SigmobRenderFeedAdapter () <WindNativeAdsManagerDelegate, AdvanceAdapter>

@property (nonatomic, strong) WindNativeAdsManager *sigmob_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;

@end

@implementation SigmobRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        
        WindAdRequest *request = [WindAdRequest request];
        request.placementId = supplier.adspotid;
        _sigmob_ad = [[WindNativeAdsManager alloc] initWithRequest:request];
        _sigmob_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_sigmob_ad loadAdDataWithCount:1];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


#pragma mark: - WindNativeAdsManagerDelegate
/// 广告加载成功回调
- (void)nativeAdsManagerSuccessToLoad:(WindNativeAdsManager *)adsManager
                            nativeAds:(NSArray<WindNativeAd *> *)nativeAdDataArray {
    
    WindNativeAd *nativeAd = nativeAdDataArray.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    SigmobRenderFeedAdView *sigmobFeedAdView = [[SigmobRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:sigmobFeedAdView feedAdElement:element];
    
    [self.adspot.manager setECPMIfNeeded:adsManager.getEcpm.integerValue supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/// 广告加载出错回调
- (void)nativeAdsManager:(WindNativeAdsManager *)adsManager
        didFailWithError:(NSError *)error {
    if (error) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
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

@end
