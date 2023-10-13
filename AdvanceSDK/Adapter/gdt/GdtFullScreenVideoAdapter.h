//
//  GdtFullScreenVideoAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceFullScreenVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GdtFullScreenVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
