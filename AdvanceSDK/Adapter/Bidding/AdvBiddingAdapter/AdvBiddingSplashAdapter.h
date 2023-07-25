//
//  AdvBiddingSplashAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/7/27.
//

#import <Foundation/Foundation.h>
#import "AdvanceSplashDelegate.h"
#import "AdvanceBaseAdapter.h"


NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingSplashAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
