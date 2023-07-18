//
//  BdFullScreenVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//
#import "AdvanceBaseAdapter.h"
#import <Foundation/Foundation.h>
#import "AdvanceFullScreenVideoDelegate.h"

@class AdvSupplier;
@class AdvanceFullScreenVideo;

NS_ASSUME_NONNULL_BEGIN

@interface BdFullScreenVideoAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
