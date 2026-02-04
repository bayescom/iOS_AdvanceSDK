# iOS 插屏广告

**素材类型：图片、视频 || 常见尺寸： 9:16、1:1**
***
<font color=#757575 size=2>**简介：** 插屏广告在App流程中弹出，当App展示插屏广告时，用户可以点击广告，访问其落地页或广告主App，也可以将其关闭，返回应用。 </font>


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
|- onInterstitialAdDidLoad: | 广告加载成功回调 |  
|- onInterstitialAdFailToLoad: error: | 广告加载失败回调 |  
|- onInterstitialAdExposured: | 广告曝光回调|  
|- onInterstitialAdFailToPresent: error: |广告展示失败回调|
|- onInterstitialAdClicked: |广告点击回调|
|- onInterstitialAdClosed: |广告关闭回调|

## 3.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 插屏广告类为AdvanceInterstitial</font></span>
- 插屏广告分为两个阶段，加载和展示。需要在广告加载成功后调用展示方法展示插屏广告。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.interstitialAd = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId extra:nil delegate:self];
    // 加载广告
    [self.interstitialAd loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.interstitialAd.isAdValid) {
        [self.interstitialAd showAdFromViewController:self];
    }
}
```

#### 广告回调
```
/// 广告加载成功回调
- (void)onInterstitialAdDidLoad:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告加载成功 %s %@", __func__, interstitialAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
    [self showAd];
}

/// 广告加载失败回调
-(void)onInterstitialAdFailToLoad:(AdvanceInterstitial *)interstitialAd error:(NSError *)error {
    NSLog(@"插屏广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.interstitialAd = nil;
}

/// 广告曝光回调
-(void)onInterstitialAdExposured:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告曝光回调 %s %@", __func__, interstitialAd);
}

/// 广告展示失败回调
-(void)onInterstitialAdFailToPresent:(AdvanceInterstitial *)interstitialAd error:(NSError *)error {
    NSLog(@"插屏广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.interstitialAd = nil;
}

/// 广告点击回调
- (void)onInterstitialAdClicked:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告点击回调 %s %@", __func__, interstitialAd);
}

/// 广告关闭回调
- (void)onInterstitialAdClosed:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告关闭回调 %s %@", __func__, interstitialAd);
    self.interstitialAd = nil;
}
```
