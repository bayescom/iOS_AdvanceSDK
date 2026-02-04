# iOS 全屏视频广告

**素材类型：图片、视频 || 常见尺寸： 9:16、2:1**
***
<font color=#757575 size=2>**简介：** 全屏视频广告在App运行流程中弹出，当应用展示全屏视频广告时，用户可以选择点击广告，访问其落地页或广告主App，也可以将其关闭，返回App</font>

## 1.广告位属性及方法说明

| 属性| 	介绍|
|--------- |---------------|  
|isAdValid |广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败| 

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: customExt: |广告位初始化方法<br>adspotid: 广告位id <br>customExt: 自定义拓展参数（可为空）| 
|- loadAd |加载广告| 
|- showAdFromViewController: |展示广告|

| 代理方法| 	介绍|
|--------- |---------------|  
|- didFinishLoadingADPolicyWithSpotId: | 广告策略服务加载成功 |  
|- didFailLoadingADSourceWithSpotId: error: description: | 广告策略或者渠道广告加载失败 |  
|- didStartLoadingADSourceWithSpotId: sourceId: | 广告位中某一个广告源开始加载广告<br> sourceId :将要加载的渠道id|  
|- didFinishLoadingFullscreenVideoADWithSpotId: |全屏视频广告数据拉取成功|
|- fullscreenVideoDidDownLoadForSpotId: extra: |全屏视频缓存成功|
|- fullscreenVideoDidStartPlayingForSpotId: extra: |全屏视频开始播放|
|- fullscreenVideoDidEndPlayingForSpotId: extra: |全屏视频播放完成|
|- fullscreenVideoDidClickForSpotId: extra: |全屏视频广告被点击|
|- fullscreenVideoDidCloseForSpotId: extra: |全屏视频广告被关闭|
|- fullscreenVideoDidClickSkipForSpotId: extra:|全屏视频广告点击跳过|
- <span style="background-color: #297497"><font  color=#FFFFF> 广告展示时机: 请在 -fullscreenVideoDidDownLoadForSpotId: 回调后再允许用户观看广告，可保证播放流畅和展示流畅，用户体验更好。
</font></span>
***

## 2.接入代码示例
- <span style="background-color: #297497"><font  color=#FFFFF> 全屏视频广告类为AdvanceFullScreenVideo</font></span>
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId customExt:nil];
    self.advanceFullScreenVideo.delegate = self;
    [self.advanceFullScreenVideo loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.advanceFullScreenVideo.isAdValid) {
        [self.advanceFullScreenVideo showAdFromViewController:self];
    }
}
```

#### 广告回调

```
/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 全屏视频广告数据拉取成功
- (void)didFinishLoadingFullscreenVideoADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功, 正在缓存... %s", __func__);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
}

/// 全屏视频缓存成功
- (void)fullscreenVideoDidDownLoadForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告缓存成功 %s", __func__);
    [JDStatusBarNotification showWithStatus:@"视频缓存成功" dismissAfter:1.5];
}

/// 全屏视频开始播放
- (void)fullscreenVideoDidStartPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 全屏视频播放完成
- (void)fullscreenVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告播放完成 %s", __func__);
}

/// 全屏视频广告点击
- (void)fullscreenVideoDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 全屏视频点击跳过
- (void)fullscreenVideoDidClickSkipForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"点击了跳过 %s", __func__);
}

/// 全屏视频广告关闭
- (void)fullscreenVideoDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
}
```
