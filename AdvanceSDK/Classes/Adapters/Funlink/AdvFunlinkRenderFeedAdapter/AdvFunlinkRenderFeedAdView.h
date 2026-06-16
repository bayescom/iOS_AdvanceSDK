//
//  AdvFunlinkRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import <FLinkAdSaas/FLinkAdSaas.h>

@interface AdvFunlinkRenderFeedAdView : UIView <FLinkNativeAdRenderProtocol>
@property (nonatomic, strong) NSArray *clickableViews;

@end
