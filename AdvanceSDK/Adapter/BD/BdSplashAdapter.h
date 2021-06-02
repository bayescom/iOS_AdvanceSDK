//
//  BdSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import <Foundation/Foundation.h>
#import "AdvanceSplashDelegate.h"

@class AdvSupplier;
@class AdvanceSplash;

NS_ASSUME_NONNULL_BEGIN

@interface BdSplashAdapter : NSObject
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
