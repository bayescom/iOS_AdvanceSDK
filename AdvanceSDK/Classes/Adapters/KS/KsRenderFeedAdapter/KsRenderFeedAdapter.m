//
//  KsRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "KsRenderFeedAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "KsRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface KsRenderFeedAdapter () <KSNativeAdsManagerDelegate, AdvanceAdapter>

@property (nonatomic, strong) KSNativeAdsManager *ks_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;

@end

@implementation KsRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _ks_ad = [[KSNativeAdsManager alloc] initWithPosId:_supplier.adspotid];
        _ks_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_ks_ad loadAdDataWithCount:1];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - KSNativeAdsManagerDelegate

- (void)nativeAdsManagerSuccessToLoad:(KSNativeAdsManager *)adsManager nativeAds:(NSArray<KSNativeAd *> *_Nullable)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"KSNative.com" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    KSNativeAd *nativeAd = nativeAdDataArray.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    KsRenderFeedAdView *ksFeedAdView = [[KsRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:ksFeedAdView feedAdElement:element];
    
    [self.adspot.manager setECPMIfNeeded:nativeAd.ecpm supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)nativeAdsManager:(KSNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithNativeAd:(KSNativeAd *)nativeAd {
    KSMaterialMeta *data = nativeAd.data;
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = data.appName.length ? data.appName : data.productName;
    element.desc = data.adDescription;
    element.iconUrl = data.appIconImage.imageURL;
    NSMutableArray *urlList = [NSMutableArray array];
    for (KSAdImage *image in data.imageArray) {
        [urlList addObject:image.imageURL];
    }
    element.imageUrlList = [urlList copy];
    element.mediaWidth = data.imageArray.firstObject.width;
    element.mediaHeight = data.imageArray.firstObject.height;
    element.buttonText = data.actionDescription;
    element.isVideoAd = (data.materialType == KSAdMaterialTypeVideo);
    if (element.isVideoAd) {
        element.mediaWidth = data.videoCoverImage.width;
        element.mediaHeight = data.videoCoverImage.height;
    }
    element.videoDuration = data.videoDuration;
    element.appRating = data.appScore;
    
    return element;
}

@end
