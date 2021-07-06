//
//  KsInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import <Foundation/Foundation.h>
#import "AdvanceInterstitialDelegate.h"


NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceInterstitial;

@interface KsInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceInterstitial *)adspot;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
