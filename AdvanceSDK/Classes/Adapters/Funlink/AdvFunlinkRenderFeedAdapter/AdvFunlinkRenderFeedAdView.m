//
//  AdvFunlinkRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRenderFeedAdView.h"

@implementation AdvFunlinkRenderFeedAdView

#pragma mark - FLinkNativeAdRenderProtocol
// 广告主视图
- (UIView *)mainAdView {
    return self; // 决定可否曝光
}

// 广告图
- (UIImageView *)mainImageView {
    return nil;
}

// 可点击view的数组
- (NSArray *)clickViewArray {
    return self.clickableViews;
}

-(void)dealloc {
    
}

@end
