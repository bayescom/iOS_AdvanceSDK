//
//  KsNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//


#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
