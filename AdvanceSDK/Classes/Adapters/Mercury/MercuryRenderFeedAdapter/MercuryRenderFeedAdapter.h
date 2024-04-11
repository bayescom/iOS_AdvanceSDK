//
//  MercuryRenderFeedAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "AdvanceRenderFeedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryRenderFeedAdapter : NSObject

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
