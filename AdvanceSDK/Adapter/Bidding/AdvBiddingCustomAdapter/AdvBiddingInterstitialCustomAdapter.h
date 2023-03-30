//
//  AdvBiddingInterstitialCustomAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2023/3/29.
//

#import <Foundation/Foundation.h>
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingInterstitialCustomAdapter : NSObject<ABUCustomInterstitialAdapter>

@end

NS_ASSUME_NONNULL_END
