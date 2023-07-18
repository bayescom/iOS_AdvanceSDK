//
//  GdtFullScreenVideoAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBaseAdapter.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceFullScreenVideoDelegate.h"

@class AdvSupplier;
@class AdvanceFullScreenVideo;

NS_ASSUME_NONNULL_BEGIN

@interface GdtFullScreenVideoAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
