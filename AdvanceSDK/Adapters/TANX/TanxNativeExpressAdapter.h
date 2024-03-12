//
//  TanxNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
