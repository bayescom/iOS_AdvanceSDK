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

@class AdvanceBanner;

NS_ASSUME_NONNULL_BEGIN

@interface MercuryBannerAdapter : NSObject

@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceBanner *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
