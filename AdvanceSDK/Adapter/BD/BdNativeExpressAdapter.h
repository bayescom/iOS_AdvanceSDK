//
//  BdNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
