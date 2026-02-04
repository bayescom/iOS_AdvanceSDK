# iOS 全屏视频广告

**素材类型：图片、视频 || 常见尺寸： 9:16、2:1**
***
<font color=#757575 size=2>**简介：** 全屏视频广告在App运行流程中弹出，当应用展示全屏视频广告时，用户可以选择点击广告，访问其落地页或广告主App，也可以将其关闭，返回App</font>

## 1.广告位接口说明
| 属性| 	介绍|
|--------- |---------------|  
|muted |设定是否静音播放视频，默认为YES| 
|isAdValid |广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败| 

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: extra: delegate: |广告位初始化方法<br>adspotid: 广告位id <br>extra: 自定义扩展参数（可为空）<br>delegate: 广告代理对象| 
|- loadAd |加载广告| 
|- showAdFromViewController: |展示广告<br>viewController: 当前视图控制器| 

## 2.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
|- onFullScreenVideoAdDidLoad: | 广告加载成功回调 |  
|- onFullScreenVideoAdFailToLoad: error: | 广告加载失败回调 |  
|- onFullScreenVideoAdExposured: | 广告曝光回调|  
|- onFullScreenVideoAdFailToPresent: error: |广告展示失败回调|
|- onFullScreenVideoAdClicked: |广告点击回调|
|- onFullScreenVideoAdClosed: |广告关闭回调|
|- onFullScreenVideoAdDidPlayFinish: |广告播放结束回调|

## 3.接入代码示例
- <span style="background-color: #297497"><font  color=#FFFFF> 全屏视频广告类为AdvanceFullScreenVideo</font></span>
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.fullscreenVideoAd = [[AdvanceFullScreenVideo alloc] initWithAdspotId:self.adspotId extra:nil delegate:self];
    // 加载广告
    [self.fullscreenVideoAd loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.fullscreenVideoAd.isAdValid) {
        [self.fullscreenVideoAd showAdFromViewController:self];
    }
}
```

#### 广告回调

```
/// 广告加载成功回调
- (void)onFullScreenVideoAdDidLoad:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告加载成功 %s %@", __func__, fullscreenVideoAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
}

/// 广告加载失败回调
-(void)onFullScreenVideoAdFailToLoad:(AdvanceFullScreenVideo *)fullscreenVideoAd error:(NSError *)error {
    NSLog(@"全屏视频广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.fullscreenVideoAd = nil;
}

/// 广告曝光回调
-(void)onFullScreenVideoAdExposured:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告曝光回调 %s %@", __func__, fullscreenVideoAd);
}

/// 广告展示失败回调
-(void)onFullScreenVideoAdFailToPresent:(AdvanceFullScreenVideo *)fullscreenVideoAd error:(NSError *)error {
    NSLog(@"全屏视频广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.fullscreenVideoAd = nil;
}

/// 广告点击回调
- (void)onFullScreenVideoAdClicked:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告点击回调 %s %@", __func__, fullscreenVideoAd);
}

/// 广告关闭回调
- (void)onFullScreenVideoAdClosed:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频广告关闭回调 %s %@", __func__, fullscreenVideoAd);
    self.fullscreenVideoAd = nil;
}

/// 广告播放结束回调
- (void)onFullScreenVideoAdDidPlayFinish:(AdvanceFullScreenVideo *)fullscreenVideoAd {
    NSLog(@"全屏视频播放完成 %s", __func__);
}
```
