//
//  AdvTanxRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import <UIKit/UIKit.h>
#import <TanxSDK/TanxSDK.h>
#import "AdvanceRenderFeedAdViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvTanxRenderFeedAdView : TXAdFeedView <TXAdFeedManagerDelegate, AdvanceRenderFeedAdViewProtocol>

@end

NS_ASSUME_NONNULL_END
