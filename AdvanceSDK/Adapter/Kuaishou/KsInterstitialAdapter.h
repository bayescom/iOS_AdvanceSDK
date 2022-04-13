//
//  KsInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import <Foundation/Foundation.h>
#import "AdvanceInterstitialDelegate.h"
#import "AdvBaseAdPosition.h"

NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceInterstitial;

@interface KsInterstitialAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
