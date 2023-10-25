//
//  AdvBiddingInterstitial.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/24.
//

#import <Foundation/Foundation.h>
#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroMoreInterstitialTrigger : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
