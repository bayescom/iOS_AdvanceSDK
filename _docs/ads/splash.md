# iOS 开屏广告 

**素材类型：图片、视频 || 常见尺寸： 2:3、9:16**
***
<font color=#757575 size=2>**简介：** 开屏广告以App启动作为曝光时机，可展示5S的广告。用户可以点击广告跳转到落地面或相应的广告主App内；或者点击右上角的“跳过”按钮，跳转到app主界面，若用户不进行任何点击，则等待广告展示完毕后也会进入您的app主界面。</font>

## 1.广告位接口说明
| 属性| 	介绍|
|--------- |---------------|  
|bottomLogoView |广告底部Logo视图| 
|viewController |用于广告跳转的视图控制器| 
|isAdValid |广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败| 

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: extra: delegate: |广告位初始化方法<br>adspotid: 广告位id <br>extra: 自定义扩展参数（可为空）<br>delegate: 广告代理对象| 
|- loadAd |加载广告| 
|- showAdInWindow: |展示广告<br>window: 传入viewController所在的window,  或者keyWindow| 

## 2.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
|- onSplashAdDidLoad: | 广告加载成功回调 |  
|- onSplashAdFailToLoad: error: | 广告加载失败回调 |  
|- onSplashAdExposured: | 广告曝光回调|  
|- onSplashAdFailToPresent: error: |广告展示失败回调|
|- onSplashAdClicked: |广告点击回调|
|- onSplashAdClosed: |广告关闭回调|

**注意事项:**

- 每次加载开屏广告需使用最新的实例, **不要使用懒加载**, 不要进行本地存储, 或计时器持有的操作

- 保证在开屏广告生命周期内(包括请求,曝光成功后的展现时间内),不要更换rootVC, 也不要对Window进行操作

## 3.接入代码示例
- <span style="background-color: #297497"><font  color=#FFFFF> 开屏广告类为 AdvanceSplash</font></span>
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.splashAd = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                      extra:@{@"testExt": @1}
                                                   delegate:self];
    self.splashAd.viewController = self;
    self.splashAd.bottomLogoView = [self createBottomLogoView];
    // 加载广告
    [self.splashAd loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.splashAd.isAdValid) {
        [self.splashAd showAdInWindow:self.view.window];
    }
}
```

#### 广告回调

```
/// 广告加载成功回调
- (void)onSplashAdDidLoad:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告加载成功 %s %@", __func__, splashAd);
//    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
    [self showAdInWindow];
}

/// 广告加载失败回调
-(void)onSplashAdFailToLoad:(AdvanceSplash *)splashAd error:(NSError *)error {
    NSLog(@"开屏广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.splashAd = nil;
}

/// 广告曝光回调
-(void)onSplashAdExposured:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告曝光回调 %s %@", __func__, splashAd);
}

/// 广告展示失败回调
-(void)onSplashAdFailToPresent:(AdvanceSplash *)splashAd error:(NSError *)error {
    NSLog(@"开屏广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.splashAd = nil;
}

/// 广告点击回调
- (void)onSplashAdClicked:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告点击回调 %s %@", __func__, splashAd);
}

/// 广告关闭回调
- (void)onSplashAdClosed:(AdvanceSplash *)splashAd {
    NSLog(@"开屏广告关闭回调 %s %@", __func__, splashAd);
    self.splashAd = nil;
}
```
