# AdvanceSDK

[![Version](https://img.shields.io/cocoapods/v/AdvanceSDK.svg?style=flat)](https://cocoapods.org/pods/AdvanceSDK)
[![License](https://img.shields.io/cocoapods/l/AdvanceSDK.svg?style=flat)](https://cocoapods.org/pods/AdvanceSDK)
[![Platform](https://img.shields.io/cocoapods/p/AdvanceSDK.svg?style=flat)](https://cocoapods.org/pods/AdvanceSDK)

# 私有化部署改动内容

将 AdvanceSDK 转自用，可能需要进行替换更新内容如下：

1.请求策略地址：修改全局字符串变量 AdvanceSDKRequestUrl 为自己的请求地址链接地址为自己的请求地址即可，也就是[**Stella**](https://github.com/bayescom/EasyAds-Pro_Stella)项目搭建的私有化服务的请求地址：http://yourdomain.com/stella

2.请求加密key：全局字符串变量**AdvanceSDKSecretKey**为自己的key，key需要是16位字符串

# AdvanceSDK对接文档-iOS

本文档为AdvanceSDK接入参考文档。用户可以参考Example工程中的配置以及各广告位接入代码进行开发。

目前聚合的广告平台有：倍业，广点通，穿山甲，快手，百度，Sigmob，Tanx。

## 注意事项:
- App Tracking Transparency（ATT）适用于请求用户授权，访问与应用相关的数据以跟踪用户或设备。 访问 https://developer.apple.com/documentation/apptrackingtransparency 了解更多信息。
- SKAdNetwork（SKAN）是 Apple 的归因解决方案，可帮助广告客户在保持用户隐私的同时衡量广告活动。 使用 Apple 的 SKAdNetwork 后，即使 IDFA 不可用，广告网络也可以正确获得应用安装的归因结果。 访问 https://developer.apple.com/documentation/storekit/skadnetwork 了解更多信息。

## Checklist
- 应用编译环境升级至 Xcode14.1 及以上版本
- 调试阶段尽量使用真机, 以便获取idfa, 如果获取不到idfa, 则打开idfa开关, iphone 打开idfa 开关的的过程:设置 -> 隐私 -> 跟踪 -> 允许App请求跟踪
- 支持苹果 ATT：从 iOS 14 开始，若开发者设置 App Tracking Transparency 向用户申请跟踪授权，在用户授权之前IDFA 将不可用。 如果用户拒绝此请求，应用获取到的 IDFA 将自动清零，可能会导致您的广告收入的降低
- 要获取 App Tracking Transparency 权限，请更新您的 Info.plist，添加 NSUserTrackingUsageDescription 字段和自定义文案描述。代码示例：

```
<key>NSUserTrackingUsageDescription</key>
<string>该标识符将用于向您投放个性化广告</string>
```

## 目前AdvanceSDK支持统一管理的广告位类型为：

- [开屏广告位(Splash)](./_docs/ads/splash.md)
- [横幅广告位(Banner)](./_docs/ads/banner.md)
- [插屏广告位（Interstitial)](./_docs/ads/interstitial.md)
- [激励视频(RewardVideo)](./_docs/ads/reward.md)
- [全屏视频视频(FullScreenVideo)](./_docs/ads/fullscreen.md)
- [原生模板信息流广告位(NativeExpress)](./_docs/ads/nativeExpress.md)
- [原生自渲染信息流广告位(RenderFeed)](./_docs/ads/renderFeed.md)


## SDK项目部署

自动部署可以省去您工程配置的时间。iOS SDK会通过CocoaPods进行发布，推荐您使用自动部署。

### Step1:安装CocoaPods

- 如果您未安装过cocoaPods，可以通过以下命令行进行安装。

```
$ sudo gem install cocoapods
```

### Step2: 配置Podfile文件

```
$ pod init
```

- 打开Podfile文件，应该是如下内容（具体内容可能会有一些出入）：

```
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
platform :ios, '12.0'
target '你的项目名称' do
  # Pods for 你的项目名称
end
```

- 修改Podfile文件，引入聚合SDK、Adapter和其他渠道SDK，并指定版本号。如下所示：
- iOS最低支持版本为：12.0

```
platform :ios, '12.0'
target '你的项目名称' do

  # 引入聚合SDK（必须）
  pod 'AdvanceSDK', '5.x.x' #指定你想要的版本号
  
  # 引入倍业Adapter
  pod 'AdvanceSDK/MercuryAdapter'
  pod 'MercurySDK', '4.6.3' #指定你想要的版本号
  
  # 引入穿山甲Adapter
  pod 'AdvanceSDK/CSJAdapter'
  pod 'Ads-CN-Beta', '7.3.0.4', :subspecs => ['BUAdSDK'] #指定你想要的版本号
  
  # 引入优量汇Adapter
  pod 'AdvanceSDK/GDTAdapter'
  pod 'GDTMobSDK', '4.15.65' #指定你想要的版本号
  
  # 引入快手Adapter
  pod 'AdvanceSDK/KSAdapter'
  pod 'KSAdSDK', '4.11.20.1' #指定你想要的版本号
  
  # 引入百度Adapter
  pod 'AdvanceSDK/BaiduAdapter'
  pod 'BaiduMobAdSDK', '10.022' #指定你想要的版本号
  
  # 引入TanxAdapter
  pod 'AdvanceSDK/TanxAdapter'
  pod 'TanxSDK', '3.7.21' #指定你想要的版本号
  
  # 引入SigMobAdapter
  pod 'AdvanceSDK/SigmobAdapter'
  pod 'SigmobAd-iOS', '4.20.5' #指定你想要的版本号
  
end
```

### Step3：使用CocoaPods进行SDK部署
- 通过CocoaPods安装SDK前，确保CocoaPods索引已经更新。可以通过运行以下命令来更新索引：

```
$ pod repo update
```

- 运行命令进行安装：

```
$ pod install
```

- 也可以将上述两条命令合成为如下命令:

```
$ pod install --repo-update
```

### Step4 网络配置（必须)
苹果公司在iOS9中升级了应用网络通信安全策略，默认推荐开发者使用HTTPS协议来进行网络通信，并限制HTTP协议的请求，sdk需要app支持http请求：

![902CA139-0E5F-4165-BF3F-4B3E74404EF3](./_docs/imgs/902CA139-0E5F-4165-BF3F-4B3E74404EF3.png)

### Step5 链接设置(必须)

在Target->Build Settings -> Other Linker Flags中添加-ObjC, 字母o和c大写。

![1DFAFEBE-74DC-44D4-BFCC-EF0E194C5D45](./_docs/imgs/1DFAFEBE-74DC-44D4-BFCC-EF0E194C5D45.png)

## 全局初始化设置
<span style="background-color: #297497"><font  color=#FFFFF>appId必须要在具体广告位初始化之前设置</font></span>

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    ...
    
    [AdvanceSDKManager setAppId:@"your appId"];    
    
    return YES;
}
```

## 接入代码
您可以点击上述支持的广告位类型进行查看具体广告位的对接代码，也可以运行自带的Example工程，参考Example工程中的接入代码进行开发。

## 验收测试
代码对接完成后请提供测试包给我方对接测试人员进行验收。
