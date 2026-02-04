# iOS 开屏广告 

**素材类型：图片、视频 || 常见尺寸： 2:3、9:16**
***
<font color=#757575 size=2>**简介：** 开屏广告以App启动作为曝光时机，可展示5S的广告。用户可以点击广告跳转到落地面或相应的广告主App内；或者点击右上角的“跳过”按钮，跳转到app主界面，若用户不进行任何点击，则等待广告展示完毕后也会进入您的app主界面。</font>

## 1.广告位属性及方法说明

| 属性| 	介绍|
|--------- |---------------|  
|bottomLogoView |广告底部Logo视图| 
|isAdValid |广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败| 

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: customExt: viewController: |广告位初始化方法<br>adspotid: 广告位id <br>customExt: 自定义拓展参数（可为空）<br>viewController: 广告加载容器（建议传入当前控制器，广告需要提前加载可传nil)| 
|- loadAd |加载广告| 
|- showInWindow: |展示广告<br>window: 传入viewController所在的window,  或者keyWindow| 

| 代理方法| 	介绍|
|--------- |---------------|  
|- didFinishLoadingADPolicyWithSpotId: | 广告策略服务加载成功 |  
|- didFailLoadingADSourceWithSpotId: error: description: | 广告策略或者渠道广告加载失败 |  
|- didStartLoadingADSourceWithSpotId: sourceId: | 广告位中某一个广告源开始加载广告<br> sourceId :将要加载的渠道id|  
|- didFinishLoadingSplashADWithSpotId: |开屏广告数据拉取成功|
|- splashDidShowForSpotId: extra: |开屏广告展示成功|
|- splashDidClickForSpotId: extra: |开屏广告被点击|
|- splashDidCloseForSpotId: extra: |开屏广告被关闭|

**注意事项:**

- 每次加载开屏广告需使用最新的实例, **不要使用懒加载**, 不要进行本地存储, 或计时器持有的操作

- 保证在开屏广告生命周期内(包括请求,曝光成功后的展现时间内),不要更换rootVC, 也不要对Window进行操作

## 2.接入代码示例
- <span style="background-color: #297497"><font  color=#FFFFF> 开屏广告类为 AdvanceSplash</font></span>
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                       customExt:@{@"testExt": @1}
                                                  viewController:self];
    self.advanceSplash.delegate = self;
    self.advanceSplash.bottomLogoView = [self createBottomLogoView];
    // 加载广告
    [self.advanceSplash loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.advanceSplash.isAdValid) {
        [self.advanceSplash showInWindow:self.view.window];
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
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    [self removeBgImgView];
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 开屏广告数据拉取成功
- (void)didFinishLoadingSplashADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    [self showAd];
}

/// 广告曝光成功
- (void)splashDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光成功 %s", __func__);
    // 移除背景图
    [self removeBgImgView];
}

/// 广告点击
- (void)splashDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)splashDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
    self.advanceSplash = nil;
}
```
