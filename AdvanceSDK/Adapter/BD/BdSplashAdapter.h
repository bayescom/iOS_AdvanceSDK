//
//  BdSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import <Foundation/Foundation.h>
#import "AdvanceSplashDelegate.h"
#import "AdvBaseAdPosition.h"
@class AdvSupplier;
@class AdvanceSplash;

NS_ASSUME_NONNULL_BEGIN

@interface BdSplashAdapter : AdvBaseAdPosition

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
