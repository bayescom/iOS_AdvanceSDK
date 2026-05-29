//
//  AdvanceRenderFeedAdViewProtocol.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/28.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AdvanceCommonAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceRenderFeedAdViewProtocol <NSObject>

- (instancetype)initWithNativeAd:(id)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(nullable id)manager
                  viewController:(nullable UIViewController *)viewController;

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView;

- (UIView *)logoImageView;

- (UIView *)videoAdView;

- (CGSize)logoSize;

@end

NS_ASSUME_NONNULL_END
