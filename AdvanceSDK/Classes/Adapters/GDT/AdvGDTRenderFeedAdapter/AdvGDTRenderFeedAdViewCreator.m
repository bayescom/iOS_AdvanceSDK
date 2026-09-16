//
//  AdvGDTRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/12.
//

#import "AdvGDTRenderFeedAdViewCreator.h"

@interface AdvGDTRenderFeedAdViewCreator ()
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *dataObject;
@property (nonatomic, strong) GDTUnifiedNativeAdView *adView;

@end

@implementation AdvGDTRenderFeedAdViewCreator

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject
                            adView:(GDTUnifiedNativeAdView *)adView {
    self = [super init];
    if (self) {
        _dataObject = dataObject;
        _adView = adView;
    }
    return self;
}

- (void)refreshData {
    
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    [self.adView registerDataObject:self.dataObject clickableViews:clickableViews];

    // 保持现有行为：注册后，将 GDT 子视图移到聚合广告容器。
    NSArray<UIView *> *subviews = [self.adView.subviews copy];
    for (UIView *view in subviews) {
        [containerView addSubview:view];
    }
}

- (UIView *)logoImageView {
    return self.adView.logoView;
}

- (CGSize)logoSize {
    return CGSizeMake(kGDTLogoImageViewDefaultWidth, kGDTLogoImageViewDefaultHeight);
}

- (UIView *)videoAdView {
    return self.adView.mediaView;
}

@end
