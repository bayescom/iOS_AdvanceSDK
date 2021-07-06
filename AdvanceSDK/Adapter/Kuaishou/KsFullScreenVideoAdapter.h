//
//  KsFullScreenVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "AdvanceFullScreenVideoDelegate.h"
NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceFullScreenVideo;

@interface KsFullScreenVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;// 标记并行渠道为了找到响应的adapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceFullScreenVideo *)adspot;
- (void)deallocAdapter;

- (void)loadAd;

- (void)showAd;


@end

NS_ASSUME_NONNULL_END
