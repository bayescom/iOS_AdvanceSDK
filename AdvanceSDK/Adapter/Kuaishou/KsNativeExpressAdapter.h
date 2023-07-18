//
//  KsNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvanceBaseAdapter.h"
#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvSupplier;
@class AdvanceNativeExpress;

@interface KsNativeExpressAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
