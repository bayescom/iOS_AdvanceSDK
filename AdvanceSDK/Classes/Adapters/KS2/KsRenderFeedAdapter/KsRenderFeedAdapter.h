//
//  KsRenderFeedAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsRenderFeedAdapter : NSObject

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
