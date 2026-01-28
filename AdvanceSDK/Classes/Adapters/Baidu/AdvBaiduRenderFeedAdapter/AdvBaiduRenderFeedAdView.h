//
//  AdvBaiduRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import <Foundation/Foundation.h>
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvBaiduRenderFeedAdView : UIView

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject
                          delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                         adapterId:(NSString *)adapterId;

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView;

@property (nonatomic, strong, readonly) UIView *logoImageView;

@property (nonatomic, strong, readonly) UIView *videoAdView;

@property (nonatomic, assign, readonly) CGSize logoSize;

@end

NS_ASSUME_NONNULL_END
