//
//  AdvMercuryRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/12.
//

#import "AdvMercuryRenderFeedAdViewCreator.h"

@interface AdvMercuryRenderFeedAdViewCreator ()
@property (nonatomic, strong) MercuryUnifiedNativeAdDataObject *dataObject;
@property (nonatomic, strong) MercuryUnifiedNativeAdView *adView;

@end

@implementation AdvMercuryRenderFeedAdViewCreator

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject
                            adView:(MercuryUnifiedNativeAdView *)adView {
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
    [self.adView registerDataObject:self.dataObject clickableViews:clickableViews closeableViews:nil];
}

- (CGSize)logoSize {
    if (!self.dataObject.logoUrl.length) {
        return CGSizeMake(25, 15);
    }
    return CGSizeMake(40, 15);
}

-(UIView *)logoImageView {
    return self.adView.logoView;
}

-(UIView *)videoAdView {
    return self.adView.mediaView;
}

@end
