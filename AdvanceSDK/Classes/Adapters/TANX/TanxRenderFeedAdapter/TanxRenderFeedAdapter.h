//
//  TanxRenderFeedAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxRenderFeedAdapter : NSObject

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
