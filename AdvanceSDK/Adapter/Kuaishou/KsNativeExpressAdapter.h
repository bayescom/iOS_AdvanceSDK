//
//  KsNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvSupplier;
@class AdvanceNativeExpress;

@interface KsNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot;

- (void)loadAd;


@end

NS_ASSUME_NONNULL_END
