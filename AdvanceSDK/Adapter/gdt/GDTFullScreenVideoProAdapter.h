//
//  GDTFullScreenVideoProAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/29.
//
#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import "AdvanceFullScreenVideoDelegate.h"

@class AdvSupplier;
@class AdvanceFullScreenVideo;

NS_ASSUME_NONNULL_BEGIN

@interface GDTFullScreenVideoProAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
