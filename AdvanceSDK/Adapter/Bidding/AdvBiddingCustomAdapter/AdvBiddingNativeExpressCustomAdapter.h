//
//  AdvBiddingNativeExpressCustomAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/8/8.
//

#import <Foundation/Foundation.h>
//#import "AdvBidding.h"
#import "AdvBiddingCongfig.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingNativeExpressCustomAdapter : NSObject<ABUCustomNativeAdapter>

@end

NS_ASSUME_NONNULL_END
