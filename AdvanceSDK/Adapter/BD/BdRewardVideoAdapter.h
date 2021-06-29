//
//  BdRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardVideoDelegate.h"

@class AdvSupplier;
@class AdvanceRewardVideo;

NS_ASSUME_NONNULL_BEGIN

@interface BdRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceRewardVideo *)adspot;
- (void)deallocAdapter;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
