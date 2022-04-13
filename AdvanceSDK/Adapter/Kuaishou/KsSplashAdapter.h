//
//  KsSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/20.
//
#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceSplashDelegate.h"
NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceSplash;

@interface KsSplashAdapter : AdvBaseAdPosition

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
