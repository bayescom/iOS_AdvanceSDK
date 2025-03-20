//
//  SigmobRenderFeedAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SigmobRenderFeedAdapter : NSObject

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
