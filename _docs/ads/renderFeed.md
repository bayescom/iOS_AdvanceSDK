# iOS 自渲染信息流广告

**素材类型：图片、视频 || 常见尺寸： 16:9、9:16**
***
<font color=#757575 size=2>**简介：** 自渲染广告在原生广告中是相对比较高级的用法，开发者可获取广告的所有素材内容进行自定义布局的广告渲染。一般开发者会嵌套在产品自身的布局中实现。</font>

## 1.广告位代理方法及广告对象说明

| 广告素材数据对象| 	介绍|
|--------- |---------------|  
|AdvRenderFeedAdElement |自渲染信息流广告素材：<br>包含广告标题、广告描述、广告图标、多媒体信息、广告有效性等| 

| 广告位数据对象| 	介绍|
|--------- |---------------|  
|AdvRenderFeedAd |用户通过回调获取的广告位信息：<br>包含广告素材对象、自渲染展示容器、广告平台logo、视频播放视图等 <br>-registerClickableViews: andCloseableView: 此方法用于绑定可点击、可关闭的视图| 

| 代理方法| 	介绍|
|--------- |---------------|  
|- didFinishLoadingADPolicyWithSpotId: | 广告策略服务加载成功 |  
|- didFailLoadingADSourceWithSpotId: error: description: | 广告策略或者渠道广告加载失败 |  
|- didStartLoadingADSourceWithSpotId: sourceId: | 广告位中某一个广告源开始加载广告<br> sourceId :将要加载的渠道id|  
|- didFinishLoadingRenderFeedAd: spotId:|自渲染信息流广告数据拉取成功|
|- renderFeedAdDidShowForSpotId: extra: |广告曝光的回调|
|- renderFeedAdDidClickForSpotId: extra: |广告被点击的回调|
|- renderFeedAdDidCloseForSpotId: extra:|广告被关闭的回调|
|- renderFeedAdDidCloseDetailPageForSpotId: extra: |广告详情页被关闭的回调|
|- renderFeedVideoDidEndPlayingForSpotId: extra: |视频广告播放完成的回调|


***

## 2.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 自渲染信息流广告类为AdvanceRenderFeed</font></span>
- 自渲染信息流广告加载分为几个阶段:加载广告获得自渲染信息流对象，用户自渲染广告素材，展示自渲染广告。
- 需要注意的是，开发者需要在当前页面持有SDK返回的AdvRenderFeedAd对象以及自渲染容器视图feedAdView。用户点击关闭按钮后，开发者需要把feedAdView视图移除。
- 开发者自渲染的视图务必添加至feedAdView容器之中。详情可参照Demo文件DemoFeedAdDisplayController.m
- 开发者创建完视图后，使用AdvRenderFeedAdElement对象更新数据。**重要：** 紧接着调用registerClickableViews: andCloseableView:进行视图绑定操作。

#### 加载广告
```
- (void)loadRenderFeedAd {
    _renderFeed = [[AdvanceRenderFeed alloc] initWithAdspotId:self.adspotId customExt:@{@"test1": @"value1"} viewController:self];
    _renderFeed.delegate = self;
    [_renderFeed loadAd];
}
```

#### 创建视图
```
- (void)buildupFeedAdView {
    /// 自渲染视图容器
    /// important：其他子视图添加至该容器中
    self.feedAdView.frame = CGRectMake(0, 0, width, height - 100);
    [self.view addSubview:self.feedAdView];
    self.feedAdView.backgroundColor = UIColor.lightGrayColor;
    
    /// icon
    self.iconImageView = [[UIImageView alloc] init];
    [self.feedAdView addSubview: self.iconImageView];
    
    ......
    
    /// 图片或者视频容器
    if (!self.feedAd.feedAdElement.isVideoAd) {
        self.imgView = [[UIImageView alloc] init];
        [self.feedAdView addSubview:self.imgView];
    } else {
        // 视频容器和广告平台logo已经在feedAdView容器内不需要开发者add，只需要设置其frame
    }
    
    ......
}
```

#### 刷新数据
```
- (void)refreshFeedAdUIWithData:(AdvRenderFeedAdElement *)element {
    self.iconImageView.frame = CGRectMake(30, 10, 40, 40);
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:element.iconUrl] placeholderImage:nil];
    
    ......    
}
```

#### 广告回调

```
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
    
    if (self.feedAd.feedAdElement.isAdValid) {
        [self buildupFeedAdView];
        [self refreshFeedAdUIWithData:self.feedAd.feedAdElement];
        [self.feedAd registerClickableViews:@[self.customLinkBtn, self.iconImageView] andCloseableView:self.closeBtn];
    }
}

/// 自渲染信息流广告关闭按钮点击
- (void)renderFeedAdDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    // 手动移除广告视图
    [self.feedAdView removeFromSuperview];
}

/// 自渲染信息流广告曝光
- (void)renderFeedAdDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}

/// 自渲染信息流广告点击
- (void)renderFeedAdDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}

/// 自渲染信息流广告关闭详情页
- (void)renderFeedAdDidCloseDetailPageForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}

/// 信息流视频广告播放完成
- (void)renderFeedVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    
}
```

