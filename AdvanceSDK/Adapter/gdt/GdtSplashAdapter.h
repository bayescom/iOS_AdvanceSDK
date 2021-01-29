//
//  GdtSplashAdapter.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Gdt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceSplashDelegate.h"

@class AdvSupplier;
@class AdvanceSplash;

NS_ASSUME_NONNULL_BEGIN

@interface GdtSplashAdapter : NSObject
@property (nonatomic, copy)   NSString *adspotid;// 标记并行渠道为了找到响应的adapter

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
