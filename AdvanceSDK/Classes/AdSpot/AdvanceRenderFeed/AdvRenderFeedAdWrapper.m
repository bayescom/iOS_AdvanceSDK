//
//  AdvRenderFeedAdWrapper.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvRenderFeedAdWrapper.h"
#import <objc/message.h>

@implementation AdvRenderFeedAdWrapper

- (instancetype)initWithFeedAdView:(UIView *)feedAdView feedAdElement:(AdvRenderFeedAdElement *)feedAdElement {
    if (self = [super init]) {
        self.feedAdView = feedAdView;
        self.feedAdElement = feedAdElement;
    }
    return self;
}


- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews andCloseableView:(UIView *)closeableView {
    SEL selector = @selector(registerClickableViews:andCloseableView:);
    ((void (*)(id, SEL, NSArray *, UIView *))objc_msgSend)(self.feedAdView, selector, clickableViews, closeableView);
}

- (UIView *)logoImageView {
    SEL selector = @selector(logoImageView);
    UIView *view = ((id (*)(id, SEL))objc_msgSend)(self.feedAdView, selector);
    return view;
}

- (CGSize )logoSize {
    SEL selector = @selector(logoSize);
    CGSize size = ((CGSize (*)(id, SEL))objc_msgSend)(self.feedAdView, selector);
    return size;
}

- (UIView *)videoAdView {
    SEL selector = @selector(videoAdView);
    UIView *view = ((id (*)(id, SEL))objc_msgSend)(self.feedAdView, selector);
    return view;
}

@end
