//
//  AdvMercuryRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import <UIKit/UIKit.h>
#import <MercurySDK/MercurySDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvMercuryRenderFeedAdView : MercuryUnifiedNativeAdView

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject
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
