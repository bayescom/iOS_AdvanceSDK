//
//  KsFullScreenVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvanceFullScreenVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsFullScreenVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
