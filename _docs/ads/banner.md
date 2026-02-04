# iOS 横幅广告

**素材类型：图片 || 常见尺寸： 7:1、5:2**
***
<font color=#757575 size=2>**简介：** Banner广告(横幅广告)一般呈现在app顶部、中部、底部任意一处，横向贯穿app页面，可在一段时间后自动刷新</font>

## 1.广告位接口说明
| 属性| 	介绍|
|--------- |---------------|  
|adSize |广告位尺寸| 
|viewController |用于广告跳转的视图控制器| 
|bannerView |获取到的Banner广告视图| 
|isAdValid |广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败| 

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: extra: delegate: |广告位初始化方法<br>adspotid: 广告位id <br>extra: 自定义扩展参数（可为空）<br>delegate: 广告代理对象| 
|- loadAd |加载广告| 

## 2.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
|- onBannerAdDidLoad: | 广告加载成功回调 |  
|- onBannerAdFailToLoad: error: | 广告加载失败回调 |  
|- onBannerAdExposured: | 广告曝光回调| 
|- onBannerAdFailToPresent: error: |广告展示失败回调|
|- onBannerAdClicked: |广告点击回调|
|- onBannerAdClosed: |广告关闭回调|


## 3.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> banner广告类为AdvanceBanner</font></span>
- 横幅广告暂不支持广告自动刷新。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
     _bannerAd = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId extra:self.ext delegate:self];
    _bannerAd.adSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width * 5.0 / 32.0);
    _bannerAd.viewController = self;
    [_bannerAd loadAd];
}
```


#### 广告回调：
```
/// 广告加载成功回调
- (void)onBannerAdDidLoad:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告加载成功 %s %@", __func__, bannerAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
    if (bannerAd.isAdValid) {
        self.bannerAdView = bannerAd.bannerView;
        [self.adShowView addSubview:self.bannerAdView];
    }
}

/// 广告加载失败回调
-(void)onBannerAdFailToLoad:(AdvanceBanner *)bannerAd error:(NSError *)error {
    NSLog(@"横幅广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.bannerAd = nil;
}

/// 广告曝光回调
-(void)onBannerAdExposured:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告曝光回调 %s %@", __func__, bannerAd);
}

/// 广告展示失败回调
-(void)onBannerAdFailToPresent:(AdvanceBanner *)bannerAd error:(NSError *)error {
    NSLog(@"横幅广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.bannerAd = nil;
}

/// 广告点击回调
- (void)onBannerAdClicked:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告点击回调 %s %@", __func__, bannerAd);
}

/// 广告关闭回调
- (void)onBannerAdClosed:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告关闭回调 %s %@", __func__, bannerAd);
    self.bannerAd = nil;
    [self.bannerAdView removeFromSuperview];
}
```

