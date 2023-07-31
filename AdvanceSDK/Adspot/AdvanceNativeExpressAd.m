//
//  AdvanceNativeExpressAd.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/4.
//

#import "AdvanceNativeExpressAd.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvanceNativeExpressAd ()
@property (nonatomic, weak) UIViewController *controller;
@end

@implementation AdvanceNativeExpressAd
- (instancetype)initWithViewController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        _controller = controller;
    }
    return self;
}

- (void)setIdentifier:(NSString *)identifier {
    _identifier = identifier;
}
- (void)render {
    if (self.controller == nil || self.expressView == nil) {
        return;
    }
    if ([self.expressView isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")] ||
        [self.expressView isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")] ||
        [self.expressView isKindOfClass:NSClassFromString(@"CSJNativeExpressAdView")]) {
        [self.expressView performSelector:@selector(setRootViewController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
        [self.expressView performSelector:@selector(setController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {// 广点通旧版信息流
        [self.expressView performSelector:@selector(setController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"GDTNativeExpressProAdView")]) {// 广点通新版信息流
        [self.expressView performSelector:@selector(setController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"BaiduMobAdSmartFeedView")]) {// 百度
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"ABUNativeAdView")]) {// bidding
        [self.expressView performSelector:@selector(render)];
    } else { // 快手 或 tanx
        
    }

}

- (void)setExpressView:(UIView *)expressView {
    _expressView = expressView;
}

- (void)setIsStopMotion:(BOOL)isStopMotion {
    _isStopMotion = isStopMotion;
    if ([self.expressView isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(self.expressView, @selector(setIsStopMotion:), isStopMotion);
    }
}

- (void)dealloc
{
//    NSLog(@"%s", __func__);
}
@end
