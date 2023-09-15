//
//  BdBannerAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/28.
//
#import "AdvanceBaseAdapter.h"
#import "AdvanceBannerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdBannerAdapter : NSObject
@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
