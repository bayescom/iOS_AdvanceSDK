//
//  KsSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/20.
//

#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsSplashAdapter : NSObject

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
