//
//  MercuryNativeExpressAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//


#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
