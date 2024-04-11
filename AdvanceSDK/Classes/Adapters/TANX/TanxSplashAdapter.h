//
//  TanxSplashAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxSplashAdapter : NSObject
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
