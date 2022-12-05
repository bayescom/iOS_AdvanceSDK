//
//  AdvBiddingRewardVideoScapegoat.h
//  AdvanceSDK
//
//  Created by MS on 2022/10/26.
//

#import <Foundation/Foundation.h>
//#import "AdvBidding.h"
#import "AdvanceRewardVideoDelegate.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif
NS_ASSUME_NONNULL_BEGIN
@class AdvBiddingRewardVideoCustomAdapter;
@interface AdvBiddingRewardVideoScapegoat : NSObject<AdvanceRewardVideoDelegate>
@property (nonatomic, weak)AdvBiddingRewardVideoCustomAdapter *a;

@end

NS_ASSUME_NONNULL_END
