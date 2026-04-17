//
//  AdvFunlinkRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import <Foundation/Foundation.h>
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceRenderFeedCommonAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvFunlinkRenderFeedAdView : UIView

- (instancetype)initWithAdData:(FLinkFeedAdData*)data
                       manager:(FLinkNativeManager *)manager
                      delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                     adapterId:(NSString *)adapterId;

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView;

@property (nonatomic, strong, readonly) UIView *logoImageView;

@property (nonatomic, strong, readonly) UIView *videoAdView;

@property (nonatomic, assign, readonly) CGSize logoSize;

@end

NS_ASSUME_NONNULL_END
