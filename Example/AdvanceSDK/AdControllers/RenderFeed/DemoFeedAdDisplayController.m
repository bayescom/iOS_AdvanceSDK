//
//  DemoFeedAdDisplayController.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2023/9/11.
//  Copyright © 2023 Cheng455153666. All rights reserved.
//

#import "DemoFeedAdDisplayController.h"
#import "JDStatusBarNotification.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AdvanceSDK/AdvanceRenderFeed.h>

@interface DemoFeedAdDisplayController () <AdvanceRenderFeedDelegate>

@property (nonatomic, strong) AdvanceRenderFeed *renderFeedAd;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, strong) UIView *feedAdView;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong, nullable) UIImageView *imgView;
@property (nonatomic, strong, nullable) UILabel *adTitleLabel;
@property (nonatomic, strong, nullable) UILabel *adDescriptionLabel;
@property (nonatomic, strong) UIButton *customLinkBtn;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation DemoFeedAdDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"自渲染信息流";
    self.view.backgroundColor = UIColor.whiteColor;
    [self loadRenderFeedAd];
}

- (void)loadRenderFeedAd {
    _renderFeedAd = [[AdvanceRenderFeed alloc] initWithAdspotId:self.adspotId extra:@{@"test1": @"value1"} delegate:self];
    _renderFeedAd.viewController = self;
    [_renderFeedAd loadAd];
}

- (void)buildupFeedAdView {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    /// 自渲染视图容器
    /// important：其他子视图添加至该容器中
    self.feedAdView.frame = CGRectMake(0, 0, width, height - 100);
    [self.view addSubview:self.feedAdView];
    self.feedAdView.backgroundColor = UIColor.lightGrayColor;
    
    /// icon
    self.iconImageView = [[UIImageView alloc] init];
    [self.feedAdView addSubview: self.iconImageView];
    
    /// 文字标题
    self.adTitleLabel = [[UILabel alloc] init];
    self.adTitleLabel.numberOfLines = 1;
    self.adTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.adTitleLabel.font = [UIFont systemFontOfSize:18];
    [self.feedAdView addSubview:self.adTitleLabel];
    
    /// 图片或者视频容器
    if (!self.feedAdWrapper.feedAdElement.isVideoAd) {
        self.imgView = [[UIImageView alloc] init];
        [self.feedAdView addSubview:self.imgView];
    } else {
        // 视频容器和广告平台logo已经在feedAdView容器内不需要开发者add，只需要设置其frame
    }
    
    /// 描述信息
    self.adDescriptionLabel = [UILabel new];
    self.adDescriptionLabel.numberOfLines = 1;
    self.adDescriptionLabel.font = [UIFont systemFontOfSize:14];
    [self.feedAdView addSubview:self.adDescriptionLabel];
    
    /// 自定义跳转按钮
    [self.feedAdView addSubview:self.customLinkBtn];
    
    /// 关闭按钮
    [self.feedAdView addSubview:self.closeBtn];
}

- (void)refreshFeedAdUIWithData:(AdvRenderFeedAdElement *)element {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    self.iconImageView.frame = CGRectMake(30, 10, 40, 40);
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:element.iconUrl] placeholderImage:nil];
    
    self.adTitleLabel.text = element.title;
    self.adTitleLabel.frame = CGRectMake(80, 20, 200, 20);
    
    self.closeBtn.frame = CGRectMake(width - 70, 10, 40, 40);
    
    CGFloat contentWidth = width - 60;
    const CGFloat imageHeight = contentWidth * ((element.mediaHeight * 1.0) / (element.mediaWidth * 1.0));
    CGFloat mediaMaxY = 0;
    if (!element.isVideoAd) { // 图片
        self.imgView.frame = CGRectMake(30, CGRectGetMaxY(self.iconImageView.frame) + 10, contentWidth, imageHeight);
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:element.imageUrlList.firstObject] placeholderImage:nil];
        mediaMaxY = CGRectGetMaxY(self.imgView.frame);
    } else { // 视频
        self.feedAdWrapper.videoAdView.frame = CGRectMake(30, CGRectGetMaxY(self.iconImageView.frame) + 10, contentWidth, imageHeight);
        mediaMaxY = CGRectGetMaxY(self.feedAdWrapper.videoAdView.frame);
    }
    
    /// 广告平台logo
    CGSize logoSize = self.feedAdWrapper.logoSize;
    self.feedAdWrapper.logoImageView.frame = CGRectMake(CGRectGetMaxX(self.feedAdView.frame) - logoSize.width - 4, 4, logoSize.width, logoSize.height);
    
    self.adDescriptionLabel.text = element.desc;
    self.adDescriptionLabel.frame = CGRectMake(30, mediaMaxY + 10, 200, 20);
    
    [self.customLinkBtn setTitle:element.buttonText forState:UIControlStateNormal];
    self.customLinkBtn.frame = CGRectMake(contentWidth - 60 ,self.adDescriptionLabel.frame.origin.y, 100, 20);
    
}


#pragma mark: - AdvanceRenderFeedDelegate
/// 广告加载成功回调
- (void)onRenderFeedAdSuccessToLoad:(AdvanceRenderFeed *)renderFeedAd feedAdWrapper:(AdvRenderFeedAdWrapper *)feedAdWrapper {
    NSLog(@"自渲染信息流广告加载成功 %s %@", __func__, renderFeedAd);
    self.feedAdWrapper = feedAdWrapper;
    self.feedAdView = feedAdWrapper.feedAdView;
    
    if (self.feedAdWrapper.feedAdElement.isAdValid) {
        [self buildupFeedAdView];
        [self refreshFeedAdUIWithData:self.feedAdWrapper.feedAdElement];
        [self.feedAdWrapper registerClickableViews:@[self.customLinkBtn, self.iconImageView] andCloseableView:self.closeBtn];
    }
}

/// 广告加载失败回调
- (void)onRenderFeedAdFailToLoad:(AdvanceRenderFeed *)renderFeedAd error:(NSError *)error {
    NSLog(@"自渲染信息流广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.renderFeedAd = nil;
}

/// 广告曝光回调
-(void)onRenderFeedAdViewExposured:(AdvRenderFeedAdWrapper *)feedAdWrapper {
    NSLog(@"自渲染信息流广告曝光回调 %s %@", __func__, feedAdWrapper);
}

/// 广告点击回调
- (void)onRenderFeedAdViewClicked:(AdvRenderFeedAdWrapper *)feedAdWrapper {
    NSLog(@"自渲染信息流广告点击回调 %s %@", __func__, feedAdWrapper);
}

/// 广告关闭回调
- (void)onRenderFeedAdViewClosed:(AdvRenderFeedAdWrapper *)feedAdWrapper {
    NSLog(@"自渲染信息流广告关闭回调 %s %@", __func__, feedAdWrapper);
    // 手动移除广告视图
    [self.feedAdView removeFromSuperview];
    self.renderFeedAd = nil;
}

/// 广告详情页关闭回调
- (void)onRenderFeedAdDidCloseDetailPage:(AdvRenderFeedAdWrapper *)feedAdWrapper {
    NSLog(@"自渲染信息流广告详情页关闭回调 %s %@", __func__, feedAdWrapper);
}

/// 视频广告播放结束回调
- (void)onRenderFeedAdDidPlayFinish:(AdvRenderFeedAdWrapper *)feedAdWrapper {
    NSLog(@"自渲染信息流广告视频播放结束回调 %s %@", __func__, feedAdWrapper);
}


- (UIButton *)customLinkBtn {
    if (!_customLinkBtn) {
        _customLinkBtn = [[UIButton alloc] init];
        [_customLinkBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        _customLinkBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _customLinkBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _closeBtn;
}

@end
