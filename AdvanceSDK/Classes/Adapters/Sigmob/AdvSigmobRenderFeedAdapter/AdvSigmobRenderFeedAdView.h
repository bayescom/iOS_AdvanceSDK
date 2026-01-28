//
//  AdvSigmobRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import <WindSDK/WindSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvSigmobRenderFeedAdView : WindNativeAdView

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                       adapterId:(NSString *)adapterId
                  viewController:(UIViewController *)viewController;

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView;

@property (nonatomic, strong, readonly) UIView *logoImageView;

@property (nonatomic, strong, readonly) UIView *videoAdView;

@property (nonatomic, assign, readonly) CGSize logoSize;

@end

NS_ASSUME_NONNULL_END
