# iOS 插屏广告

**素材类型：图片、视频 || 常见尺寸： 9:16、1:1**
***
<font color=#757575 size=2>**简介：** 插屏广告在App流程中弹出，当App展示插屏广告时，用户可以点击广告，访问其落地页或广告主App，也可以将其关闭，返回应用。 </font>


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
|- didFinishLoadingInterstitialADWithSpotId: |插屏广告数据拉取成功|
|- interstitialDidShowForSpotId: extra: |插屏广告展示成功|
|- interstitialDidClickForSpotId: extra: |插屏广告被点击|
|- interstitialDidCloseForSpotId: extra: |插屏广告被关闭|

## 2.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 插屏广告类为AdvanceInterstitial</font></span>
- 插屏广告分为两个阶段，加载和展示。需要在广告加载成功后调用展示方法展示插屏广告。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId
                                                                   customExt:nil];
    self.advanceInterstitial.delegate = self;
    [self.advanceInterstitial loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.advanceInterstitial.isAdValid) {
        [self.advanceInterstitial showAd];
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

/// 插屏广告数据拉取成功
- (void)didFinishLoadingInterstitialADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
    [self showAd];
}

/// 广告曝光
- (void)interstitialDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 广告点击
- (void)interstitialDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)interstitialDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    self.advanceInterstitial = nil;
    NSLog(@"广告关闭了 %s", __func__);
}
```
