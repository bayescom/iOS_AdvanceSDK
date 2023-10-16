//
//  BdSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdSplashAdapter : NSObject

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
