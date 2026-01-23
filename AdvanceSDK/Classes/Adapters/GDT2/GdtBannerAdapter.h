//
//  GdtBannerAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBannerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GdtBannerAdapter : NSObject

@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
