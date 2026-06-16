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
