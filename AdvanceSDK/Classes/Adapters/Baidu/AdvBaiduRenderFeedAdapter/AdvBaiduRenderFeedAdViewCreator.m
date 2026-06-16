//
//  AdvBaiduRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/12.
//

#import "AdvBaiduRenderFeedAdViewCreator.h"
#import "AdvBaiduAdLogoView.h"

@interface AdvBaiduRenderFeedAdViewCreator ()
@property (nonatomic, strong) BaiduMobAdNativeAdObject *dataObject;
@property (nonatomic, strong) BaiduMobAdNativeAdView *adView;
@property (nonatomic, strong) BaiduMobAdNativeVideoView *bdVideoView;
@property (nonatomic, strong) AdvBaiduAdLogoView *adLogoView;

@end

@implementation AdvBaiduRenderFeedAdViewCreator

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject
                            adView:(BaiduMobAdNativeAdView *)adView
                         videoView:(BaiduMobAdNativeVideoView *)videoView {
    self = [super init];
    if (self) {
        _dataObject = dataObject;
        _adView = adView;
        _bdVideoView = videoView;
    }
    return self;
}

- (void)refreshData {
    [self.dataObject trackImpression:self.adView];
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    if (_bdVideoView) {
        [_bdVideoView reSize];
        [_bdVideoView play];
    }
    if (clickableViews) {
        [self setupClickView:clickableViews];
    }
}

- (UIView *)logoImageView {
    return self.adLogoView;
}

- (CGSize)logoSize {
    return CGSizeMake(41, 14);
}

- (UIView *)videoAdView {
    return self.bdVideoView;
}

#pragma mark: - Actions
- (void)setupClickView:(NSArray<UIView *> *)clickableViews {
    [clickableViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickViewAction:)];
        [obj addGestureRecognizer:gr];
    }];
}

- (void)tapClickViewAction:(UITapGestureRecognizer *)gr {
    [self.dataObject handleClick:gr.view];
}

- (AdvBaiduAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvBaiduAdLogoView alloc] init];
    }
    return _adLogoView;
}

@end
