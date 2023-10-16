//
//  TanxNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/7/14.
//

#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
