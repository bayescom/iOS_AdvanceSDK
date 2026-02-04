# iOS 横幅广告

**素材类型：图片 || 常见尺寸： 7:1、5:2**
***
<font color=#757575 size=2>**简介：** Banner广告(横幅广告)一般呈现在app顶部、中部、底部任意一处，横向贯穿app页面，可在一段时间后自动刷新</font>

## 1.广告位代理方法及属性说明

| 属性| 	介绍|
|--------- |---------------|  
|adContainer |显示横幅广告的容器| 
|refreshInterval |刷新时间| 
|isAdValid |广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败| 

| 代理方法| 	介绍|
|--------- |---------------|  
|- didFinishLoadingADPolicyWithSpotId: | 广告策略服务加载成功 |  
|- didFailLoadingADSourceWithSpotId: error: description: | 广告策略或者渠道广告加载失败 |  
|- didStartLoadingADSourceWithSpotId: sourceId: | 广告位中某一个广告源开始加载广告<br> sourceId :将要加载的渠道id|  
|- didFinishLoadingBannerADWithSpotId: |横幅广告数据拉取成功|
|- bannerView: didShowAdWithSpotId: extra: |横幅广告展示成功|
|- bannerView: didClickAdWithSpotId: extra: |横幅广告被点击|
|- bannerView: didCloseAdWithSpotId: extra: |横幅广告被关闭|

***

## 2.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> banner广告类为AdvanceBanner</font></span>
- 横幅广告需要设置广告显示容器。开发者可以设置广告轮播时间控制广告轮播的时间，默认轮播时间为30秒。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
     self.bannerAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*5/32.0)];
     
    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId adContainer:self.bannerAdView customExt:self.ext viewController:self];
    self.advanceBanner.delegate = self;
    self.advanceBanner.refreshInterval = 30;
    [self.advanceBanner loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.advanceBanner.isAdValid) {
        [self.advanceBanner showAd];
    }
}
```


#### 广告回调：
```
/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// Banner广告数据拉取成功
- (void)didFinishLoadingBannerADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    [self showAd];
    [self.adShowView addSubview:self.bannerAdView];
}

/// 广告曝光
- (void)bannerView:(UIView *)bannerView didShowAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 广告点击
- (void)bannerView:(UIView *)bannerView didClickAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)bannerView:(UIView *)bannerView didCloseAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
    [bannerView removeFromSuperview];
}
```

