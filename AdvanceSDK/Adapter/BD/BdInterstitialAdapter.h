//
//  BdInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/6/21.
//

#import "AdvanceBaseAdapter.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceInterstitialDelegate.h"
@class AdvSupplier;
@class AdvanceInterstitial;

NS_ASSUME_NONNULL_BEGIN

@interface BdInterstitialAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
