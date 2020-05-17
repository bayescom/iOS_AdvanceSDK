//
//  CsjSplashAdapter.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceSplashDelegate.h"

@class AdvanceSplash;

NS_ASSUME_NONNULL_BEGIN

@interface CsjSplashAdapter : NSObject

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceSplash *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
