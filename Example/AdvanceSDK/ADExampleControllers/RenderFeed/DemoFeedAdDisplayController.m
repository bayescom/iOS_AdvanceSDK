//
//  DemoFeedAdDisplayController.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2023/9/11.
//  Copyright © 2023 Cheng455153666. All rights reserved.
//

#import "DemoFeedAdDisplayController.h"
#import <AdvanceRenderFeed.h>
#import <AdvRenderFeedAd.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DemoFeedAdDisplayController () <AdvanceRenderFeedDelegate>

@property (nonatomic, strong) AdvanceRenderFeed *renderFeed;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
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
    _renderFeed = [[AdvanceRenderFeed alloc] initWithAdspotId:self.adspotId customExt:@{@"test1": @"value1"} viewController:self];
    _renderFeed.delegate = self;
    [_renderFeed loadAd];
}

- (void)buildupFeedAdView {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    /// 自渲染视图容器
    /// important：其他子视图添加至该容器中
    self.feedAdView.frame = CGRectMake(0, 100, width, height - 120);
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
    if (!self.feedAd.feedAdElement.isVideoAd) {
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
        self.feedAd.videoAdView.frame = CGRectMake(30, CGRectGetMaxY(self.iconImageView.frame) + 10, contentWidth, imageHeight);
        mediaMaxY = CGRectGetMaxY(self.feedAd.videoAdView.frame);
    }
    
    /// 广告平台logo
    CGSize logoSize = self.feedAd.logoSize;
    self.feedAd.logoImageView.frame = CGRectMake(CGRectGetMaxX(self.feedAdView.frame) - logoSize.width, 0, logoSize.width, logoSize.height);
    
    self.adDescriptionLabel.text = element.desc;
    self.adDescriptionLabel.frame = CGRectMake(30, mediaMaxY + 10, 200, 20);
    
    [self.customLinkBtn setTitle:element.buttonText forState:UIControlStateNormal];
    self.customLinkBtn.frame = CGRectMake(contentWidth - 60 ,self.adDescriptionLabel.frame.origin.y, 100, 20);
    
}

// MARK: ======================= AdvanceRenderFeedDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 信息流广告数据拉取成功
- (void)didFinishLoadingRenderFeedAd:(AdvRenderFeedAd *)feedAd spotId:(NSString *)spotId {
    self.feedAd = feedAd;
    self.feedAdView = feedAd.feedAdView;
    
    [self buildupFeedAdView];
    [self refreshFeedAdUIWithData:self.feedAd.feedAdElement];
    [self.feedAd registerClickableViews:@[self.customLinkBtn, self.iconImageView] andCloseableView:self.closeBtn];
}

/// 自渲染信息流广告曝光
- (void)renderFeedAdDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}

/// 自渲染信息流广告点击
- (void)renderFeedAdDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}

/// 自渲染信息流广告关闭按钮点击
- (void)renderFeedAdDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    // 手动移除广告视图
    [self.feedAdView removeFromSuperview];
}

/// 自渲染信息流广告关闭详情页
- (void)renderFeedAdDidCloseDetailPageForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}

/// 信息流视频广告播放完成
- (void)renderFeedVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
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
