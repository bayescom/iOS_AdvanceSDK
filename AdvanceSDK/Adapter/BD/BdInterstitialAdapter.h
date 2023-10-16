//
//  BdInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/6/21.
//

#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
