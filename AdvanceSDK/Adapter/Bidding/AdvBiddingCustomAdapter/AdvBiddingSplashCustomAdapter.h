//
//  AdvBiddingSplashCustomAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/7/27.
//

#import <Foundation/Foundation.h>
//#import "AdvBidding.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingSplashCustomAdapter : NSObject<ABUCustomSplashAdapter>

@end

NS_ASSUME_NONNULL_END
