//
//  MercuryBannerAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceBannerDelegate.h"

@class AdvSupplier;
@class AdvanceBanner;

NS_ASSUME_NONNULL_BEGIN

@interface MercuryBannerAdapter : NSObject
@property (nonatomic, copy)   NSString *adspotid;// 标记并行渠道为了找到响应的adapter

@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceBanner *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
