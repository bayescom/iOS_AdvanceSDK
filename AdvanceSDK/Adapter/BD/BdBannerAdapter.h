//
//  BdBannerAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/28.
//

#import <Foundation/Foundation.h>
#import "AdvanceBannerDelegate.h"

@class AdvSupplier;
@class AdvanceBanner;

NS_ASSUME_NONNULL_BEGIN

@interface BdBannerAdapter : NSObject
@property (nonatomic, copy) NSString *adspotid;// 标记并行渠道为了找到响应的adapter

@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceBanner *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
