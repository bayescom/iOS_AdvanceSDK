//
//  AdvBiddingNativeScapegoat.h
//  AdvanceSDK
//
//  Created by MS on 2022/10/25.
//

#import <Foundation/Foundation.h>
//#import "AdvBidding.h"
#import "AdvanceNativeExpressDelegate.h"


#import <AdvanceSDK/AdvanceNativeExpress.h>
#import <AdvanceSDK/AdvanceNativeExpressView.h>



# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@class AdvBiddingNativeExpressCustomAdapter;
@interface AdvBiddingNativeScapegoat : NSObject<AdvanceNativeExpressDelegate>
@property (nonatomic, weak)AdvBiddingNativeExpressCustomAdapter *a;
@end

NS_ASSUME_NONNULL_END
