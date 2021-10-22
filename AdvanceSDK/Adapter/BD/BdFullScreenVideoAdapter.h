//
//  BdFullScreenVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//
#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import "AdvanceFullScreenVideoDelegate.h"

@class AdvSupplier;
@class AdvanceFullScreenVideo;

NS_ASSUME_NONNULL_BEGIN

@interface BdFullScreenVideoAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
