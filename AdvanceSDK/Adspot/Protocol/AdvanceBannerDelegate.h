//
//  AdvanceBannerProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceBannerProtocol_h
#define AdvanceBannerProtocol_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceBannerDelegate <AdvanceBaseDelegate>
@optional

#pragma 请移步AdvanceBaseDelegate
- (void)advanceAdMaterialLoadSuccess;
@end

#endif
