//
//  KsInterstitialAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import <Foundation/Foundation.h>
#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsInterstitialAdapter : NSObject
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
