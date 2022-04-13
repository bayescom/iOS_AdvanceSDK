//
//  KsFullScreenVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import "AdvanceFullScreenVideoDelegate.h"
NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceFullScreenVideo;

@interface KsFullScreenVideoAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
