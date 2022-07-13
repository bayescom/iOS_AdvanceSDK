//
//  TanxSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/7/13.
//  Copyright © 2022 Cheng455153666. All rights reserved.
//

#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceSplashDelegate.h"

@class AdvSupplier;
@class AdvanceSplash;


NS_ASSUME_NONNULL_BEGIN

@interface TanxSplashAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
