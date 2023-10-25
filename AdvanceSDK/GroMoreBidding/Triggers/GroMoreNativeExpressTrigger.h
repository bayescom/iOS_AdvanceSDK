//
//  GroMoreNativeExpressTrigger.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/25.
//

#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroMoreNativeExpressTrigger : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
