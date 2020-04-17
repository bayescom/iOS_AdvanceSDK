//
//  GdtFullScreenVideoAdapter.h
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceFullScreenVideoDelegate.h"

@class AdvanceFullScreenVideo;

NS_ASSUME_NONNULL_BEGIN

@interface GdtFullScreenVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceFullScreenVideo *)adspot;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
