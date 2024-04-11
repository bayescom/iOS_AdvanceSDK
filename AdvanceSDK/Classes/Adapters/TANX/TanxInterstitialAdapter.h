//
//  TanxInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
