//
//  CsjInterstitialProAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/20.
//


#import "AdvanceBaseAdapter.h"
#import <Foundation/Foundation.h>
#import "AdvanceInterstitialDelegate.h"

@class AdvSupplier;
@class AdvanceInterstitial;


NS_ASSUME_NONNULL_BEGIN

@interface CsjInterstitialProAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
