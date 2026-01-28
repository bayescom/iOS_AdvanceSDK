//
//  AdvCSJRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvCSJRenderFeedAdView : UIView

- (instancetype)initWithNativeAd:(BUNativeAd *)nativeAd
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
