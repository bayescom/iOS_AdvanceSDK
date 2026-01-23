//
//  KsRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import <Foundation/Foundation.h>
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceRenderFeedDelegate.h"
#import "AdvanceRenderFeed.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsRenderFeedAdView : UIView

- (instancetype)initWithNativeAd:(KSNativeAd *)nativeAd
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
