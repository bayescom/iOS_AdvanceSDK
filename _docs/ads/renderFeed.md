# iOS 自渲染信息流广告

**素材类型：图片、视频 || 常见尺寸： 16:9、9:16**
***
<font color=#757575 size=2>**简介：** 自渲染广告在原生广告中是相对比较高级的用法，开发者可获取广告的所有素材内容进行自定义布局的广告渲染。一般开发者会嵌套在产品自身的布局中实现。</font>

## 1.广告位接口说明
| 属性| 	介绍|
|--------- |---------------|  
|viewController |用于广告跳转的视图控制器|  

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: extra: delegate: |广告位初始化方法<br>adspotid: 广告位id <br>extra: 自定义扩展参数（可为空）<br>delegate: 广告代理对象| 
|- loadAd |加载广告| 

## 2.广告对象说明
| 广告素材信息| 	介绍|
|--------- |---------------|  
|AdvRenderFeedAdElement |自渲染信息流广告素材：<br>包含广告标题、广告描述、广告图标、多媒体信息、广告有效性等| 

| 广告包装类信息| 	介绍|
|--------- |---------------|  
|AdvRenderFeedAdWrapper |用户通过回调获取的广告包装类信息：<br>包含广告素材对象、自渲染展示容器、广告平台logo、视频播放视图等 <br>-registerClickableViews: andCloseableView: 此方法用于绑定可点击、可关闭的视图| 

## 3.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
|- onRenderFeedAdSuccessToLoad: feedAdWrapper: | 广告加载成功回调 |  
|- onRenderFeedAdFailToLoad: error: | 广告加载失败回调 |  
|- onRenderFeedAdViewExposured: | 广告曝光回调|  
|- onRenderFeedAdViewClicked: |广告点击回调|
|- onRenderFeedAdViewClosed: |广告关闭回调|
|- onRenderFeedAdDidCloseDetailPage: |广告详情页关闭回调|
|- onRenderFeedAdDidPlayFinish: |视频广告播放结束回调|


## 4.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 自渲染信息流广告类为AdvanceRenderFeed</font></span>
- 自渲染信息流广告加载分为几个阶段:加载广告获得自渲染信息流对象和用户自渲染广告素材，展示自渲染广告。
- 需要注意的是，开发者需要在当前页面持有SDK返回的AdvRenderFeedAdWrapper对象以及自渲染容器视图feedAdView。用户点击关闭按钮后，开发者需要把feedAdView视图移除。
- 开发者自渲染的视图务必添加至feedAdView容器之中。详情可参照Demo文件DemoFeedAdDisplayController.m
- 开发者创建完视图后，使用AdvRenderFeedAdElement对象更新数据。**重要：** 紧接着调用registerClickableViews: andCloseableView:进行视图绑定操作。

#### 加载广告
```
- (void)loadRenderFeedAd {
    _renderFeedAd = [[AdvanceRenderFeed alloc] initWithAdspotId:self.adspotId extra:@{@"test1": @"value1"} delegate:self];
    _renderFeedAd.viewController = self;
    [_renderFeedAd loadAd];
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
```

