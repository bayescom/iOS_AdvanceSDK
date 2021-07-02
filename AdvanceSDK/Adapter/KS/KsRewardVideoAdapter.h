//
//  KsRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceRewardVideo;

@interface KsRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceRewardVideo *)adspot;
- (void)deallocAdapter;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
