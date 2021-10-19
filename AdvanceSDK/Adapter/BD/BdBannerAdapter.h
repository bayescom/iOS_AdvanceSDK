//
//  BdBannerAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/28.
//
#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import "AdvanceBannerDelegate.h"

@class AdvSupplier;
@class AdvanceBanner;

NS_ASSUME_NONNULL_BEGIN

@interface BdBannerAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
