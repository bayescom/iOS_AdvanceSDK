//
//  AdvBiddingInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2023/3/27.
//

#import "AdvBaseAdPosition.h"
#import "AdvanceInterstitialDelegate.h"
@class AdvSupplier;
@class AdvanceInterstitial;

NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingInterstitialAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
