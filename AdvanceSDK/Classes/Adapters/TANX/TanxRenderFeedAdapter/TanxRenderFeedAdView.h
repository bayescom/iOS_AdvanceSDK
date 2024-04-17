//
//  TanxRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import <UIKit/UIKit.h>
#import <TanxSDK/TanxSDK.h>
#import "AdvanceRenderFeedDelegate.h"
#import "AdvanceRenderFeed.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxRenderFeedAdView : TXAdFeedView <TXAdFeedManagerDelegate>

- (instancetype)initWithBinder:(TXAdFeedBinder *)binder
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
