//
//  DemoFeedAdDisplayController.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2023/9/11.
//  Copyright © 2023. All rights reserved.
//

#import "DemoFeedAdDisplayController.h"
#import "JDStatusBarNotification.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AdvanceSDK/AdvanceRenderFeed.h>

@interface DemoFeedAdDisplayController () <AdvanceRenderFeedDelegate>

@property (nonatomic, strong) AdvanceRenderFeed *renderFeedAd;
@property (nonatomic, strong) AdvRenderFeedAdData *feedAdData;
@property (nonatomic, strong) AdvRenderFeedAdView *feedAdView;

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
    if (!self.feedAdData.isVideoAd) {
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

- (void)refreshFeedAdUIWithData:(AdvRenderFeedAdData *)data {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    self.iconImageView.frame = CGRectMake(30, 10, 40, 40);
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:data.iconUrl] placeholderImage:nil];
    
    self.adTitleLabel.text = data.title;
    self.adTitleLabel.frame = CGRectMake(80, 20, 200, 20);
    
    self.closeBtn.frame = CGRectMake(width - 70, 10, 40, 40);
    
    CGFloat contentWidth = width - 60;
    const CGFloat imageHeight = contentWidth * ((data.mediaHeight * 1.0) / (data.mediaWidth * 1.0));
    CGFloat mediaMaxY = 0;
    if (!data.isVideoAd) { // 图片
        self.imgView.frame = CGRectMake(30, CGRectGetMaxY(self.iconImageView.frame) + 10, contentWidth, imageHeight);
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:data.imageUrlList.firstObject] placeholderImage:nil];
        mediaMaxY = CGRectGetMaxY(self.imgView.frame);
    } else { // 视频
        self.feedAdView.videoAdView.frame = CGRectMake(30, CGRectGetMaxY(self.iconImageView.frame) + 10, contentWidth, imageHeight);
        mediaMaxY = CGRectGetMaxY(self.feedAdView.videoAdView.frame);
    }
    
    /// 广告平台logo
    CGSize logoSize = self.feedAdView.logoSize;
    self.feedAdView.logoImageView.frame = CGRectMake(CGRectGetMaxX(self.feedAdView.frame) - logoSize.width - 4, 4, logoSize.width, logoSize.height);
    
    self.adDescriptionLabel.text = data.desc;
    self.adDescriptionLabel.frame = CGRectMake(30, mediaMaxY + 10, 200, 20);
    
    [self.customLinkBtn setTitle:data.buttonText forState:UIControlStateNormal];
    self.customLinkBtn.frame = CGRectMake(contentWidth - 60 ,self.adDescriptionLabel.frame.origin.y, 100, 20);
    
}


#pragma mark: - AdvanceRenderFeedDelegate
/// 广告加载成功回调
- (void)onRenderFeedAdSuccessToLoad:(AdvanceRenderFeed *)renderFeedAd feedAdView:(AdvRenderFeedAdView *)feedAdView feedAdData:(AdvRenderFeedAdData *)feedAdData {
    NSLog(@"自渲染信息流广告加载成功 %s %@", __func__, renderFeedAd);
    self.feedAdData = feedAdData;
    self.feedAdView = feedAdView;
    
    [self.feedAdView refreshData];
    [self buildupFeedAdView];
    [self refreshFeedAdUIWithData:self.feedAdData];
    [self.feedAdView registerClickableViews:@[self.customLinkBtn, self.iconImageView]];
}

/// 广告加载失败回调
- (void)onRenderFeedAdFailToLoad:(AdvanceRenderFeed *)renderFeedAd error:(NSError *)error {
    NSLog(@"自渲染信息流广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.renderFeedAd = nil;
}

/// 广告曝光回调
-(void)onRenderFeedAdViewExposured:(AdvRenderFeedAdView *)feedAdView {
    NSLog(@"自渲染信息流广告曝光回调 %s %@", __func__, feedAdView);
}

/// 广告点击回调
- (void)onRenderFeedAdViewClicked:(AdvRenderFeedAdView *)feedAdView {
    NSLog(@"自渲染信息流广告点击回调 %s %@", __func__, feedAdView);
}

/// 广告详情页关闭回调
- (void)onRenderFeedAdDidCloseDetailPage:(AdvRenderFeedAdView *)feedAdView {
    NSLog(@"自渲染信息流广告详情页关闭回调 %s %@", __func__, feedAdView);
}

/// 视频广告播放结束回调
- (void)onRenderFeedAdDidPlayFinish:(AdvRenderFeedAdView *)feedAdView {
    NSLog(@"自渲染信息流广告视频播放结束回调 %s %@", __func__, feedAdView);
}

- (void)onCloseViewAction:(UIButton *)sender {
    NSLog(@"自渲染信息流广告关闭 %s %@", __func__, sender);
    // 手动移除广告视图
    [self.feedAdView removeFromSuperview];
    self.renderFeedAd = nil;
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
        [_closeBtn addTarget:self action:@selector(onCloseViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
