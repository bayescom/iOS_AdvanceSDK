//
//  SigmobSplashAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SigmobSplashAdapter : NSObject
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
