//
//  BdRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import <Foundation/Foundation.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import "AdvanceRenderFeedDelegate.h"
#import "AdvanceRenderFeed.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdRenderFeedAdView : UIView

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject
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
