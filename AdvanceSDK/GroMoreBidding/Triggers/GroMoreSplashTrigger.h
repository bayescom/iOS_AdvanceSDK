//
//  GroMoreSplashTrigger.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import <Foundation/Foundation.h>
#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroMoreSplashTrigger : NSObject

@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
