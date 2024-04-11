//
//  AdvanceRenderFeed.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 自渲染信息流广告
@interface AdvanceRenderFeed : AdvanceBaseAdSpot

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController;

-(void)loadAd;

@end

NS_ASSUME_NONNULL_END
