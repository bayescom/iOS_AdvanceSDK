//
//  TanxNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/7/14.
//

#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceNativeExpressDelegate.h"

@class AdvSupplier;
@class AdvanceNativeExpress;

NS_ASSUME_NONNULL_BEGIN

@interface TanxNativeExpressAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
