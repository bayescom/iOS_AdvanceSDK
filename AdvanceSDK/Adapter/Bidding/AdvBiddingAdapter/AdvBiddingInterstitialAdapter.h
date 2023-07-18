//
//  AdvBiddingInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2023/3/27.
//

#import "AdvanceBaseAdapter.h"
#import "AdvanceInterstitialDelegate.h"
@class AdvSupplier;
@class AdvanceInterstitial;

NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingInterstitialAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
