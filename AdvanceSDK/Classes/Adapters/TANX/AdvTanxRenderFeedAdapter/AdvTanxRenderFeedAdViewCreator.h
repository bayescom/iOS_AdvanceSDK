//
//  AdvTanxRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <TanxSDK/TanxSDK.h>

@interface AdvTanxRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithBinder:(TXAdFeedBinder *)binder
                        adView:(TXAdFeedView *)adView
                     videoView:(TXAdFeedPlayerView *)videoView;

@end
