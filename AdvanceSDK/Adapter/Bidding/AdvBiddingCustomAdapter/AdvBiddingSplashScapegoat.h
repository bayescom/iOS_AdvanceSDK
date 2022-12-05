//
//  AdvBiddingSplashScapegoat.h
//  AdvanceSDK
//
//  Created by MS on 2022/9/28.
//

#import <Foundation/Foundation.h>
//#import "AdvBidding.h"
#import "AdvanceSplashDelegate.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif
NS_ASSUME_NONNULL_BEGIN
@class AdvBiddingSplashCustomAdapter;
@interface AdvBiddingSplashScapegoat : NSObject<AdvanceSplashDelegate>
@property (nonatomic, weak)AdvBiddingSplashCustomAdapter *a;

@end

NS_ASSUME_NONNULL_END
