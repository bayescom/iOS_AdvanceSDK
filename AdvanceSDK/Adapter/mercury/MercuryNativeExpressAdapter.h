//
//  MercuryNativeExpressAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceNativeExpressDelegate.h"

@class AdvSupplier;
@class AdvanceNativeExpress;

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
