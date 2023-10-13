//
//  BdFullScreenVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//

#import "AdvanceFullScreenVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdFullScreenVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
