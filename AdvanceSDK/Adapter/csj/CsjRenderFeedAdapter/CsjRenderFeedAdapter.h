//
//  CsjRenderFeedAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface CsjRenderFeedAdapter : NSObject

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
