//
//  GdtRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import <UIKit/UIKit.h>
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceRenderFeedDelegate.h"
#import "AdvanceRenderFeed.h"

NS_ASSUME_NONNULL_BEGIN

@interface GdtRenderFeedAdView : GDTUnifiedNativeAdView

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject
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
