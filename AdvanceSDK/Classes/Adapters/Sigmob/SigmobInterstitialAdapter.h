//
//  SigmobInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SigmobInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
