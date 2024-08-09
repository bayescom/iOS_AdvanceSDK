//
//  BdRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import "BdRenderFeedAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdNative.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "BdRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface BdRenderFeedAdapter () <BaiduMobAdNativeAdDelegate, AdvanceAdapter>

@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;

@end

@implementation BdRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdNative alloc] init];
        _bd_ad.publisherId = supplier.mediaid;
        _bd_ad.adUnitTag = supplier.adspotid;
        _bd_ad.adDelegate = self;
        _bd_ad.presentAdViewController = _adspot.viewController;
    }
    return self;
}

- (void)loadAd {
    [_bd_ad requestNativeAds];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - BaiduMobAdNativeAdDelegate

- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"BDAdErrorDomain" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    BaiduMobAdNativeAdObject *dataObject = nativeAds.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    BdRenderFeedAdView *bdFeedAdView = [[BdRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:bdFeedAdView feedAdElement:element];
    
    [self.adspot.manager setECPMIfNeeded:[[dataObject getECPMLevel] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
    
}

- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:errCode.intValue userInfo:@{@"msg": (message ?: @"")}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(BaiduMobAdNativeAdObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.text;
    element.iconUrl = dataObject.iconImageURLString;
    if (dataObject.morepics) { // 三图
        element.imageUrlList = dataObject.morepics;
    } else if (dataObject.mainImageURLString.length) { // 单图
        element.imageUrlList = @[dataObject.mainImageURLString];
    }
    element.mediaWidth = dataObject.w.integerValue;
    element.mediaHeight = dataObject.h.integerValue;
    element.buttonText = dataObject.actButtonString;
    element.isVideoAd = (dataObject.materialType == VIDEO);
    element.videoDuration = dataObject.videoDuration.integerValue;
    
    return element;
}

@end

