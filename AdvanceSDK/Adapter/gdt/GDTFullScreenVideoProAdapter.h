//
//  GDTFullScreenVideoProAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/29.
//

#import <Foundation/Foundation.h>
#import "AdvanceFullScreenVideoDelegate.h"

@class AdvSupplier;
@class AdvanceFullScreenVideo;

NS_ASSUME_NONNULL_BEGIN

@interface GDTFullScreenVideoProAdapter : NSObject
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceFullScreenVideo *)adspot;

- (void)loadAd;

- (void)showAd;


@end

NS_ASSUME_NONNULL_END
