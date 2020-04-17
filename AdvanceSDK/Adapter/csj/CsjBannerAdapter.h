//
//  CsjBannerAdapter.h
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceBannerDelegate.h"

@class AdvanceBanner;

NS_ASSUME_NONNULL_BEGIN

@interface CsjBannerAdapter : NSObject

@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceBanner *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
