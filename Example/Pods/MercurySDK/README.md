# MercurySDK集成文档

[![Version](https://img.shields.io/cocoapods/v/MercurySDK.svg?style=flat)](https://cocoapods.org/pods/MercurySDK)
[![License](https://img.shields.io/cocoapods/l/MercurySDK.svg?style=flat)](https://cocoapods.org/pods/MercurySDK)
[![Platform](https://img.shields.io/cocoapods/p/MercurySDK.svg?style=flat)](https://cocoapods.org/pods/MercurySDK)

## 概述

### 开发环境

* 开发工具：Xcode 10及以上版本

* 部署目标：iOS 9.0及以上版本

* SDK版本：官网最新版本

### 组成

* 静调库 `MercurySDK.framework`


## SDK项目部署

### 自动部署【推荐】

自动部署可以省去您工程配置的时间。iOS SDK会通过CocoaPods进行发布，推荐您使用自动部署。

#### Step 1 安装CocoaPods

CocoaPods是Swift和Objective-C Cocoa项目的依赖项管理器。它拥有超过7.1万个库，并在超过300万个应用程序中使用。CocoaPods可以帮助您优雅地扩展项目。如果您未安装过cocoaPods，可以通过以下命令行进行安装。更多详情请访问CocoaPods官网。

```
$ sudo gem install cocoapods
```
注意：安装过程可能会耗时比较长，也有可能收到网络状况导致失败，请多次尝试直到安装成功。

#### Step 2 配置Podfile文件

```
$ pod init
```

打开Podfile文件，应该是如下内容（具体内容可能会有一些出入）：
```
# platform :ios, '9.0'
target '你的项目名称' do
  # use_frameworks!
  # Pods for podTest
end
```

修改Podfile文件，将pod 'MercurySDK'添加到Podfile中，如下所示：

```
platform :ios, '9.0'
target '你的项目名称' do
  # use_frameworks!
 pod 'MercurySDK', '~> 3.1.1' # 输入你想要的版本号
  # Pods for podTest
end
```

#### Step 3 使用CocoaPods进行SDK部署
通过CocoaPods安装SDK前，确保CocoaPods索引已经更新。可以通过运行以下命令来更新索引：

```
$ pod repo update
```
运行命令进行安装：
```
$ pod install
```
也可以将上述两条命令合成为如下命令:
```
$ pod install --repo-update
```

命令执行成功后，会生成.xcworkspace文件，可以打开.xcworkspace来启动工程，如下图所示。

![aYXoHg](http://cknote.oss-cn-beijing.aliyuncs.com/aYXoHg.png)

#### Step 4 升级SDK

升级SDK时，首先要更新repo库，执行命令：
```
$ pod repo update
```
之后重新执行如下命令进行安装即可升级至最新版SDK

```
$ pod install
```
* 注意 ：只有在Podfile文件中没有指定SDK版本时，运行上述命令才会自动升级到最新版本。不然需要修改Podfile文件，手动指定SDK版本为最新版本。

#### Step 5 指定SDK版本

指定SDK版本前，请先确保repo库为最新版本，参考上一小节内容进行更新。如果需要指定SDK版本，需要在Podfile文件中，pod那一行指定版本号：

```
 pod 'MercurySDK', '~> 3.1.1'  #这里改成你想要的版本号

```
之后运行命令：

```
$ pod install

```

### 手动部署

#### Step 1

将`MercurySDK.framework`文件拖入项目中。
![ZzoNpI](http://cknote.oss-cn-beijing.aliyuncs.com/ZzoNpI.png)

需要引入的依赖库

1. MercuryAdHeader.h
2. MercuryBannerAdView.h
3. MercuryConfigManager.h
4. MercuryEnumHeader.h
5. MercuryInterstitialAd.h
6. MercuryNativeAdDataModel.h
7. MercuryNativeExpressAd.h
8. MercuryNativeExpressAdView.h
9. MercuryPrerollAdView.h
10. MercuryRewardVideoAd.h
11. MercurySDK.h
12. MercurySplashAd.h

#### Step 2
在项目的 `Build Settings` => `Other Linker Flags`中添加`-ObjC`。
![IBh5Ng](http://cknote.oss-cn-beijing.aliyuncs.com/IBh5Ng.png)

#### Step 3
在`Info.plist`中添加http支持

```
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
</dict>
```

#### Step 4 

![99D7VU](http://cknote.oss-cn-beijing.aliyuncs.com/99D7VU.png)

引入系统库

1. AdSupport.framework
2. CoreTelephony.framework
3. AVFoundation.framework
4. StoreKit.framework

---

## 接入代码

在AppDelegate头文件中导入头文件并声明实例，导入`#import <MercurySDK/MercurySDK.h>`头文件，配置SDK。

```
#import <MercurySDK/MercurySDK.h>

// MARK: ======================= SDK配置 =======================
[MercuryConfigManager setAppID:@"100255"
                 mediaKey:@"757d5119466abe3d771a211cc1278df7"];
// 是否打印日志
[MercuryConfigManager openDebug:YES];


```


### 开屏广告

#### 基本信息
开屏广告以App启动作为曝光时机，提供5s的可感知广告展示。用户可以点击广告跳转到目标页面；或者点击右上角的“跳过”按钮，跳转到app内容首页。**开屏广告只支持竖屏使用**。

**适用场景**：开屏广告会在您的应用开启时加载，拥有固定展示时间（一般为5秒），展示完毕后自动关闭并进入您的应用主界面。

分类：开屏广告会根据广告素材分为半屏和全屏，其中半屏开屏广告支持开发者自定义设置开屏底部的界面和跳过按钮，用以展示应用Logo等。

| ![uoN1QO](http://cknote.oss-cn-beijing.aliyuncs.com/uoN1QO.jpg)| ![MSLs23](http://cknote.oss-cn-beijing.aliyuncs.com/MSLs23.jpg) |
|----------------------------------------------------------------------|----------------------------------------------------------------------|


#### 主要API

##### 生命周期回调

您可以按照需求实现代理，跟踪生命周期事件的回调。

```Objective-C

@optional

/// 开屏广告模型加载成功
/// @param splashAd 广告数据
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd;

/// 开屏广告成功曝光
/// @param splashAd 广告数据
- (void)mercury_splashAdSuccessPresentScreen:(MercurySplashAd *)splashAd;

/// 开屏广告曝光失败
/// @param error 异常返回
- (void)mercury_splashAdFailError:(nullable NSError *)error;

/// 应用进入后台时回调
/// @param splashAd 广告数据
- (void)mercury_splashAdApplicationWillEnterBackground:(MercurySplashAd *)splashAd;

/// 开屏广告曝光回调
/// @param splashAd 广告数据
- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd;

/// 开屏广告点击回调
/// @param splashAd 广告数据
- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd;

/// 开屏广告将要关闭回调
/// @param splashAd 广告数据
- (void)mercury_splashAdWillClosed:(MercurySplashAd *)splashAd;

/// 开屏广告关闭回调
/// @param splashAd 广告数据
- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd;

/// 开屏广告剩余时间回调
- (void)mercury_splashAdLifeTime:(NSUInteger)time;
```

需要实现上述回调，需要先设置delegate:

```Objective-C
可以在初始化时设置
_ad = [[MercurySplashAd alloc] initAdWithAdspotId:@"10002436" delegate:nil];
或
_ad.delegate = self;
```

#### 接入代码示例

```Objective-C

@interface AppDelegate () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *ad;

@end

/// 开屏
- (void)splashShow {
    _ad = [[MercurySplashAd alloc] initAdWithAdspotId:@"广告位Id" delegate:self];
    // controller 必须有值，否则无法弹出开屏广告
    _ad.controller = self;
    // 设置在广告未加载完成时的占位图
    _ad.placeholderImage = [UIImage imageNamed:@"LaunchImage_img"];
    // 设置半图时展示的Logo
    _ad.logoImage = [UIImage imageNamed:@"app_logo"];
    // 请求广告
    [_ad loadAdAndShow];
}

```


### Banner广告

#### 基本信息
Banner广告(横幅广告)位于app顶部、中部、底部任意一处，横向贯穿整个app页面；当用户与app互动时，Banner广告会停留在屏幕上，并可在一段时间后自动刷新

**适用场景**：Banner广告展现场景非常灵活，常见的展现场景为：文章页末尾，详情页面底部，信息流顶部等。

样式:

![L3PlKf](http://cknote.oss-cn-beijing.aliyuncs.com/L3PlKf.png)


> **推荐Banner宽高比** 
> Banner的宽高比为固定`6.4:1`，开发者在嵌入Banner时，可以手动设置Banner条的宽度用来满足场景需求，根据宽高比动态调整高度，以此保证显示效果

#### 主要API

##### 生命周期回调

```Objective-C
@optional
/// 请求广告条数据成功后调用
- (void)mercury_bannerViewDidReceived;

/// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(nullable NSError *)error;

/// banner条被用户关闭时调用
- (void)mercury_bannerViewWillClose;

/// banner条曝光回调
- (void)mercury_bannerViewWillExposure;

/// banner条点击回调
- (void)mercury_bannerViewClicked;

```

需要实现上述回调，需要先设置delegate:

```Objective-C
可以在初始化时设置
_bannerView = [[MercuryBannerAdView alloc] initWithFrame:CGRectZero
                                                adspotId:self.adspotId
                                                delegate:self];
或                                               
_bannerView.delegate = self;
```

#### 接入代码示例

初始化代码

```Objective-C
_bannerView = [[MercuryBannerAdView alloc] initWithFrame:CGRectZero
                                               adspotId:self.adspotId
                                               delegate:self];
_bannerView.controller = self;
// 广告刷新时间(秒) 30 - 120 低于30的会按30处理；高于120的会按120处理
_bannerView.interval = [_reloadTimeTxtF.text intValue];
// 刷新是否使用动画
_bannerView.animationOn = self.animateSwitch.isOn;
// 是否展示关闭按钮
_bannerView.showCloseBtn = self.showCloseSwitch.isOn;
// 设置代理 如初始化已传入 可不用再设置
_bannerView.delegate = self;

// 推荐使用 6.4:1 来展示banner
CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*5/32.0);
    _bannerView.frame = rect;
[self.adShowView addSubview:_bannerView];

[_bannerView loadAdAndShow];
```

### 插屏广告

#### 基本信息

插屏广告是移动广告的一种常见形式，在应用开流程中弹出，当应用展示插页式广告时，用户可以选择点按广告，访问其目标网址，也可以将其关闭，返回应用。

**适用场景**：在应用执行流程的自然停顿点，适合投放这类广告。

样式：

![22f3DY](http://cknote.oss-cn-beijing.aliyuncs.com/22f3DY.png)

#### 主要API

##### 生命周期回调

```Objective-C
@optional

/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)mercury_interstitialSuccess;

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)mercury_interstitialFailError:(NSError *)error;

/// 插屏广告将要曝光回调，插屏广告即将曝光回调该函数
- (void)mercury_interstitialWillPresentScreen;

/// 插屏广告视图曝光成功回调，插屏广告曝光成功回调该函数
- (void)mercury_interstitialDidPresentScreen;

/// 插屏广告视图曝光失败回调，插屏广告曝光失败回调该函数
- (void)mercury_interstitialFailToPresent;

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)mercury_interstitialDidDismissScreen;

/// 插屏广告曝光回调
- (void)mercury_interstitialWillExposure;

/// 插屏广告点击回调
- (void)mercury_interstitialClicked;
```

需要实现上述回调，需要先设置delegate:

```Objective-C
可以在初始化时设置
_ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
或
_ad.delegate = self;
```

#### 接入代码示例

初始化代码

```Objective-C
// 加载插屏广告
- (void)loadInterstitialAdAction {
    _ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
    [_ad loadAd];
}
// 弹出插屏广告
- (void)showInterstitialAdAction {
	[_ad presentAdFromViewController:self];
}
```

### 激励视频广告

#### 基本信息

激励视频广告是一种常见于游戏内的广告样式。用户通过开发者提供的入口，全屏观看完整视频，获得相应的奖励。

分类：目前的视频包括横版及竖版2种样式，您可以根据需要创建对应的广告位。样式图如下：

| ![i117Kb](http://cknote.oss-cn-beijing.aliyuncs.com/i117Kb.jpg) | ![ZwCury](http://cknote.oss-cn-beijing.aliyuncs.com/ZwCury.jpg) |
|----------------------------------------------------------------------|----------------------------------------------------------------------|

最终激励视频的展现样式以用户当前屏幕的方向为准。

#### 主要API

##### 生命周期回调

```Objective-C
@optional
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad;

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error;

/// 视频数据下载成功回调，已经下载过的视频会直接回调
- (void)mercury_rewardVideoAdVideoDidLoad;

/// 视频播放页即将曝光回调
- (void)mercury_rewardVideoAdWillVisible;

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed;

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose;

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked;

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective;

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish;
```
需要实现上述回调，需要先设置delegate:

```Objective-C
可以在初始化时设置
self.rewardVideoAd = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
或
_ad.delegate = self;
```

#### 接入代码示例

初始化代码

```Objective-C
// 初始化
_rewardVideoAd = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
// 加载广告
[_rewardVideoAd loadRewardVideoAd];
// 展示广告
[_rewardVideoAd showAdFromVC:self];
```

### 原生模板广告

#### 基本信息

原生模板广告是一种自动化展现的原生广告，开发者可使用几行代码快速接入。包含图片广告和视频广告两种展现形式。

**适用场景**：多用于信息流中，也可根据场景指定模板位置。

样式：

| 上图下文                                                                    | 上文下图                                                                    | 左图右文                                                                    | 左文右图                                                                    | 双图双文                                                                    |
|-------------------------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|
| ![lFuKtI](http://cknote.oss-cn-beijing.aliyuncs.com/lFuKtI.jpg) | ![zM6JEp](http://cknote.oss-cn-beijing.aliyuncs.com/zM6JEp.jpg) | ![IQMJTg](http://cknote.oss-cn-beijing.aliyuncs.com/IQMJTg.jpg) | ![c1efez](http://cknote.oss-cn-beijing.aliyuncs.com/c1efez.jpg) | ![rAYT59](http://cknote.oss-cn-beijing.aliyuncs.com/rAYT59.jpg) |


#### 主要API

##### 生命周期回调

```Objective-C
@optional
/// 拉取原生模板广告成功 | (注意: nativeExpressAdView在此方法执行结束不被强引用，nativeExpressAd中的对象会被自动释放)
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views;

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error;

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板视频广告 player 播放状态更新回调
- (void)mercury_nativeExpressAdView:(MercuryNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

```

需要实现上述回调，需要先设置delegate `MercuryNativeExpressAdDelegete`:

```Objective-C
_ad.delegate = self;
```

对于视频模板，可设置播放策略，以节省用户流量。

| 播放策略       | 描述            |
|-----------------------------|---------------|
| MercuryVideoAutoPlayPolicyWIFI   | WIFI 下自动播放    |
| MercuryVideoAutoPlayPolicyAlways | 总是自动播放，无论网络条件 |
| MercuryVideoAutoPlayPolicyNever  | 从不自动播放，无论网络条件 |

对于移入屏幕的视频，会提供对于的状态回调方法，以便开发者做出相应处理。

| 状态                         | 描述       |
|----------------------------|----------|
| MercuryMediaPlayerStatusInitial | 初始状态     |
| MercuryMediaPlayerStatusLoading | 加载中      |
| MercuryMediaPlayerStatusStarted | 开始播放     |
| MercuryMediaPlayerStatusPaused  | 用户行为导致暂停 |
| MercuryMediaPlayerStatusStoped  | 播放停止     |
| MercuryMediaPlayerStatusError   | 播放出错     |

#### 接入代码示例

初始化代码

```Objective-C
	_dataArrM = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    _ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:_adspotId];
    _ad.delegate = self;
    _ad.videoMuted = YES;	// 设置静音
    _ad.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;// 设置播放策略
    _ad.renderSize = CGSizeMake(self.view.bounds.size.width, 300);
    [_ad loadAdWithCount:_count];
```

视图请求完成后，会回调`Mercury_nativeExpressAdSuccessToLoad:views:`方法，此时返回的视图并未渲染。
> 注意，views必须在回调方法中被强持有，否则会被在回调结束后被释放。
```Objective-C
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views {
    for (NSInteger i=0; i<views.count;i++) {
        views[i].controller = self;
        views[i].adSizeMode = MercuryNativeExpressAdSizeModeAutoSize;
        if (i == 0) {
            [_dataArrM insertObject:views[i] atIndex:1];
        } else {
            [_dataArrM insertObject:views[i] atIndex:arc4random_uniform((int)views.count)];
        }
        [views[i] render];
        views[i].videoMuted = NO;
    }
}
```
渲染成功后，可获取容器所需尺寸，回调方法`mercury_nativeExpressAdViewRenderSuccess:`，此时回调的容器拥有真实尺寸。

当用户点击关闭时，会回调`mercury_nativeExpressAdViewClosed:`方法，如需要，可在此释放被关闭的视图，以节省内存。

```Objective-C
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"原生模板广告被关闭, %@", nativeExpressAdView);
    [self.tableView reloadData];
}
```

### 视频贴片

#### 基本信息

视频贴片广告是一种在视频播放到某个时机触发的广告，开发者可自定义时机进行展示。多展现于视频的前(前贴片)，中(中贴片)，后(后贴片)。可设置跳过时间，允许用户提前跳过广告。

**适用场景**：视屏播放。

样式：

![59wxbU](http://cknote.oss-cn-beijing.aliyuncs.com/59wxbU.jpg)


#### 主要API

##### 生命周期回调

```Objective-C
@optional
/// 贴片广告模型加载成功
- (void)mercury_prerollAdDidReceived;

/// 贴片广告模型加载失败
- (void)mercury_prerollAdFailToReceived:(nullable NSError *)error;

/// 贴片广告曝光失败
/// @param error 异常返回
- (void)mercury_prerollAdFailError:(nullable NSError *)error;

/// 贴片广告曝光回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdExposured:(MercuryPrerollAdView *)prerollAd;

/// 贴片广告点击回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdClicked:(MercuryPrerollAdView *)prerollAd;

/// 贴片广告关闭回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdClosed:(MercuryPrerollAdView *)prerollAd;

/// 贴片广告剩余时间回调
- (void)mercury_prerollAdLifeTime:(NSUInteger)time;

/// 播放状态变更回调
- (void)mercury_prerollAdView:(MercuryPrerollAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

```

需要实现上述回调，需要先设置delegate `MercuryPrerollAdDelegate`:

```Objective-C
可以在初始化时设置
_adView = [[MercuryPrerollAdView alloc] initWithAdspotId:self.adspotId];
或
_ad.delegate = self;
```

可以设置用户观看N秒后即可点击跳过按钮。

```Objective-C
// 播放3秒后允许跳过(默认始终显示可跳过)
_adView.showSkipTime = 3;
```

对于移入屏幕的视频，会提供对于的状态回调方法，以便开发者做出相应处理。

| 状态                         | 描述       |
|----------------------------|----------|
| MercuryMediaPlayerStatusInitial | 初始状态     |
| MercuryMediaPlayerStatusLoading | 加载中      |
| MercuryMediaPlayerStatusStarted | 开始播放     |
| MercuryMediaPlayerStatusPaused  | 用户行为导致暂停 |
| MercuryMediaPlayerStatusStoped  | 播放停止     |
| MercuryMediaPlayerStatusError   | 播放出错     |

#### 接入代码示例

初始化代码

```Objective-C
_adView = [[MercuryPrerollAdView alloc] initWithAdspotId:self.adspotId];
_adView.delegate = self;    // 设置代理
_adView.showSkipTime = 3;   // 设置可跳过时间
_adView.videoMuted = YES; // 设置静音
[_adView loadAd];    // 加载贴片

[_adView showAdWithView:aView]; // 将贴片展示在某个视图上
```

### 自渲染广告

在使用自渲染广告时，您可以获取到广告的信息，进行自定义的UI绘制。如：

#### 主要API

##### MercuryNativeAd回调方法
```
@protocol MercuryNativeAdDelegate <NSObject>

/// 广告数据回调
/// @param nativeAdDataModels 广告数据数组
/// @param error 错误信息
- (void)mercury_nativeAdLoaded:(NSArray<MercuryNativeAdDataModel *> * _Nullable)nativeAdDataModels error:(NSError * _Nullable)error;
@end
```

##### MercuryNativeAdView回调方法

```
@protocol MercuryNativeAdViewDelegate <NSObject>

@optional

/// 广告曝光回调
/// @param nativeAdView MercuryNativeAdView 实例
- (void)mercury_nativeAdViewWillExpose:(MercuryNativeAdView *)nativeAdView;

/// 广告点击回调
/// @param nativeAdView MercuryNativeAdView 实例
- (void)mercury_nativeAdViewDidClick:(MercuryNativeAdView *)nativeAdView;

/// 视频广告播放状态更改回调
/// @param nativeAdView MercuryNativeAdView 实例
/// @param status 视频广告播放状态
- (void)mercury_nativeAdView:(MercuryNativeAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

@end
```

##### MercuryMediaView回调方法

```
@class MercuryMediaView;
@protocol MercuryMediaViewDelegate <NSObject>

@optional

/**
 用户点击 MediaView 回调，当 MercuryVideoConfig userControlEnable 设为 YES，用户点击 mediaView 会回调。
 
 @param mediaView 播放器实例
 */
- (void)mercury_mediaViewDidTapped:(MercuryMediaView *)mediaView;

/**
 播放完成回调

 @param mediaView 播放器实例
 */
- (void)mercury_mediaViewDidPlayFinished:(MercuryMediaView *)mediaView;

@end
```

在实现上述事件回调之前，请务必先设置delegate:

```
self.nativeAd.delegate = self;	// 设置MercuryNativeAd代理
self.adView.delegate = self;	// 设置MercuryNativeAdView代理
self.mediaView.delegate = self; // 设置MercuryMediaView代理
```

#### 接入代码示例

> 更具体的调用方法请参考 Demo


1. 在控制器头文件中加入SDK头文件，并添加MercuryNativeAd对象

```
#import <MercurySDK/MercurySDK.h>
@property (nonatomic, strong) NSMutableArray *dataArrM;
@property (nonatomic, strong) MercuryNativeAd *nativeAd;
```

2. 在ViewController的实现文件中初始化并加载广告数据

```
_dataArrM = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
_nativeAd = [[MercuryNativeAd alloc] initAdWithAdspotId:_adspotId];
_nativeAd.delegate = self;
[_nativeAd loadAd];
```

3. 需要在广告内容准备就绪的时候展示广告。开发者需要在拿到数据的回调方法，即`mercury_nativeAdLoaded:error`里处理数据并做广告展示，可以将取到的数据进行自定义的渲染：

```
- (void)registerNativeAd:(MercuryNativeAd *)nativeAd
              dataObject:(MercuryNativeAdDataModel *)model {
    if (!model) { return; }
    
    self.titleLbl.text = model.title;
    self.descLbl.text = model.desc;
    self.sourceLbl.text = model.adsource;
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:model.logo]];
    if (model.isVideoAd) {
	// 视频类型资源 播放器类型对象可以控制其配置
	model.videoConfig.autoResumeEnable = NO;
      model.videoConfig.userControlEnable = YES;
      model.videoConfig.progressViewEnable = YES;
      model.videoConfig.coverImageEnable = YES;
      model.videoConfig.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
    } else {
    	// 图片类型资源
        }];
    }
}    	

```

> 注意：register方法中，clickableViews只接受在容器可视范围内的元素的点击（有效点击），如果不在容器内可见，即便注册到clickableViews中也不会响应广告的点击事件；
