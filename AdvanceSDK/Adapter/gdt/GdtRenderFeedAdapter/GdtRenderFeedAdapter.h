//
//  GdtRenderFeedAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvanceBaseAdapter.h"
#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GdtRenderFeedAdapter : AdvanceBaseAdapter

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
