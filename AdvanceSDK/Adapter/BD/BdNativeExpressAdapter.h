//
//  BdNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//
#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

@class AdvSupplier;
@class AdvanceNativeExpress;


NS_ASSUME_NONNULL_BEGIN

@interface BdNativeExpressAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
