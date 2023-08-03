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
