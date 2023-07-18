//
//  BdNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//
#import "AdvanceBaseAdapter.h"
#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

@class AdvSupplier;
@class AdvanceNativeExpress;


NS_ASSUME_NONNULL_BEGIN

@interface BdNativeExpressAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
