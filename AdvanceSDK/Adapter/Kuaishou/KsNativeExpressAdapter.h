//
//  KsNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvSupplier;
@class AdvanceNativeExpress;

@interface KsNativeExpressAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
