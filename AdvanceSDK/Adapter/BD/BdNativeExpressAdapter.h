//
//  BdNativeExpressAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import <Foundation/Foundation.h>
#import "AdvanceNativeExpressDelegate.h"

@class AdvSupplier;
@class AdvanceNativeExpress;


NS_ASSUME_NONNULL_BEGIN

@interface BdNativeExpressAdapter : NSObject
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
