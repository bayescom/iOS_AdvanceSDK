//
//  KsSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceSplashDelegate.h"
NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceSplash;

@interface KsSplashAdapter : NSObject
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
