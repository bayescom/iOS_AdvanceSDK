//
//  GdtInterstitialAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GdtInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
