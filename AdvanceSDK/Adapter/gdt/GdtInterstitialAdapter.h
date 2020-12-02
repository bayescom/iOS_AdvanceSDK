//
//  GdtInterstitialAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceInterstitialDelegate.h"

@class AdvSupplier;
@class AdvanceInterstitial;

NS_ASSUME_NONNULL_BEGIN

@interface GdtInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceInterstitial *)adspot;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
