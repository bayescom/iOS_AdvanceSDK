//
//  AdvRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/11.
//

#import "AdvRenderFeedAdView.h"
#import "AdvRenderFeedAdWrapper.h"

@interface AdvRenderFeedAdView ()
@property (nonatomic, strong) AdvRenderFeedAdWrapper *wrapper;

@end

@implementation AdvRenderFeedAdView

- (instancetype)initWithRenderFeedAdWrapper:(AdvRenderFeedAdWrapper *)wrapper {
    if (self = [super init]) {
        self.wrapper = wrapper;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    if (self.wrapper.view) {
        [self insertSubview:self.wrapper.view atIndex:0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.wrapper.view) {
        self.wrapper.view.frame = self.bounds;
    }
}

- (void)refreshData {
    if ([self.wrapper.viewCreator respondsToSelector:@selector(refreshData)]) {
        [self.wrapper.viewCreator refreshData];
    }
}

/**
 一般情况下，外层以AdvRenderFeedAdView作为自渲染视图容器
 广点通会在register之后将logoview和mediaview加入到GDTUnifiedNativeAdView中
 */
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews {
    if ([self.wrapper.viewCreator respondsToSelector:@selector(registerContainer:withClickableViews:)]) {
        [self.wrapper.viewCreator registerContainer:self withClickableViews:clickableViews];
    }
    if ([NSStringFromClass(self.wrapper.view.class) isEqualToString:@"GDTUnifiedNativeAdView"]) {
        [self.wrapper.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
    }
}

- (UIView *)logoImageView {
    if ([self.wrapper.viewCreator respondsToSelector:@selector(logoImageView)]) {
        UIView *view = [self.wrapper.viewCreator logoImageView];
        [self addSubview:view];
        return view;
    }
    return nil;
}

- (CGSize )logoSize {
    if ([self.wrapper.viewCreator respondsToSelector:@selector(logoSize)]) {
        return [self.wrapper.viewCreator logoSize];
    }
    return CGSizeZero;
}

- (UIView *)videoAdView {
    if ([self.wrapper.viewCreator respondsToSelector:@selector(videoAdView)]) {
        UIView *view = [self.wrapper.viewCreator videoAdView];
        [self addSubview:view];
        return view;
    }
    return nil;
}

@end
