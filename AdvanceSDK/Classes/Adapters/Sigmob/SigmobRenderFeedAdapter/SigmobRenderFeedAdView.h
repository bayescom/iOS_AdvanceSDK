//
//  SigmobRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import <WindSDK/WindSDK.h>
#import "AdvanceRenderFeedDelegate.h"
#import "AdvanceRenderFeed.h"

NS_ASSUME_NONNULL_BEGIN

@interface SigmobRenderFeedAdView : WindNativeAdView

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedDelegate>)delegate
                          adSpot:(AdvanceRenderFeed *)adSpot
                        supplier:(AdvSupplier *)supplier;

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView;

@property (nonatomic, strong, readonly) UIView *logoImageView;

@property (nonatomic, strong, readonly) UIView *videoAdView;

@property (nonatomic, assign, readonly) CGSize logoSize;

@end

NS_ASSUME_NONNULL_END
