# AdvanceSDK对接文档-IOS


本文档为AdvanceSDK接入配置参考文档。用户可以参考Example工程中的配置以及广告位接入代码进行开发。

目前聚合SDK聚合的SDK有：Mercury，广点通，穿山甲，请在对接的时候使用支持相应sdk管理的AdvanceSDK。

目前AdvanceSDK支持统一管理的广告位类型为：

- 开屏广告位(Splash)
- 横幅广告位(Banner)
- 插屏广告位（Interstitial)
- 原生模板信息流广告位(NativeExpress)
- 激励视频(RewardVideo)
- 全屏视频视频(FullScreenVideo)

> 如开发者已经集成过渠道SDK，不想再次开发，或需要管理其他类型广告位，可参考自定义开发纳入AdvanceSDK管理

## SDK项目部署

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
  # Pods for 你的项目名称
end
```

修改Podfile文件，将pod 'AdvanceSDK'添加到Podfile中，如下所示：

```
platform :ios, '9.0'
target '你的项目名称' do
  # use_frameworks!
  # Pods for 你的项目名称
  pod 'AdvanceSDK', '~> 3.2.0' # 可指定你想要的版本号
  pod 'AdvanceSDK/CSJ', 	# 如果需要导入穿山甲SDK
  pod 'AdvanceSDK/GDT', 	# 如果需要导入广点通SDK
  pod 'AdvanceSDK/Mercury' # 如果需要导入MercurySDK
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

命令执行成功后，会生成.xcworkspace文件，可以打开.xcworkspace来启动工程。

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
  pod 'AdvanceSDK', '~> 3.2.0' # 可指定你想要的版本号
  pod 'AdvanceSDK/CSJ', '~> 3.2.0'	# 如果需要导入穿山甲SDK
  pod 'AdvanceSDK/GDT', '~> 3.2.0'	# 如果需要导入广点通SDK

```
之后运行命令：

```
$ pod install

```

> 注意: 如导入穿山甲SDK出现`_OBJC_CLASS_$_XXXX`提示，可尝试以下方案:

使用Git LFS安装

[Git LFS](https://git-lfs.github.com/) 是用于使用Git管理大型文件的命令行扩展和规范。您可以按照以下步骤安装它：

步骤 1: 点击并下载 [Git LFS](https://git-lfs.github.com/) 

步骤 2: 使用以下命令安装LFS：

```
sudo sh install.sh
```
步骤 3: 检查安装是否正确：

```
git lfs version
```
步骤 4: 再次执行`pod install `

如还有问题的话，有可能是 Cocoapods 的缓存，执行这个命令`rm -rf ~/Library/Caches/CocoaPods`，重新 pod install 就可以了。

#### Step 6 网络配置（必须)

苹果公司在iOS9中升级了应用网络通信安全策略，默认推荐开发者使用HTTPS协议来进行网络通信，并限制HTTP协议的请求，sdk需要app支持http请求：

![advancesdk_support_http](./advancesdk_support_http.png)

#### Step 7 链接设置(必须)

在Target->Build Settings -> Other Linker Flags中添加-ObjC, 字母o和c大写。

![advancesdk_otherlinking](./advancesdk_otherlinking.png)

### 获取聚合SDK系统对接ID

在AdvanceSdk策略管理系统中配置聚合SDK媒体ID，和各个广告位ID，作为加载聚合SDK广告位的参数，如有疑问，请咨询我方运营人员。

例如:媒体ID：10033，广告位ID：200034 。

在系统设置sdk的参数和优先级：

![advancesdk_sdk_setting](./advancesdk_sdk_setting.png)


## 接入代码

您可以运行自带的AdvanceSDKDemo工程，参考Demo工程中的接入代码进行开发。

### 全局初始化设置

聚合SDK要正确工作需要各个SDK在app启动时正确初始化，具体各个SDK的设置方式不尽相同，请参考各个SDK的文档。


### 开屏广告

开屏广告需要传入当前ViewController作为参数，开屏广告展示时间统一为5秒钟，开发者可以设置统一的广告请求超时时间，超时时间默认为5秒。

```objective-c

#import "DemoSplashViewController.h"
#import "DemoUtils.h"
#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200034"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceSplash = [[AdvanceSplash alloc] initWithMediaId:self.mediaId
                                                       adspotId:self.adspotId
                                                 viewController:self];
    self.advanceSplash.delegate=self;
    self.advanceSplash.logoImage= [UIImage imageNamed:@"640-100"];
    self.advanceSplash.backgroundImage= [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotId:@"10002436"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkTag:SDK_ID_MERCURY];
    [self.advanceSplash loadAd];
}

// MARK: ======================= AdvanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived {
    [DemoUtils showToast:@"广告数据拉取成功"];
}

/// 广告渲染失败
- (void)advanceSplashOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告曝光成功
- (void)advanceSplashOnAdShow {
    [DemoUtils showToast:@"广告曝光成功"];
}

/// 广告展示失败
- (void)advanceSplashOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    [DemoUtils showToast:@"广告展示失败"];
}

/// 广告点击
- (void)advanceSplashOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked {
    [DemoUtils showToast:@"广告点击跳过"];
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
    [DemoUtils showToast:@"广告倒计时结束"];
}

@end

```



### 横幅广告

横幅广告需要设置广告容器，当前的ViewController作为参数。开发者可以设置广告轮播时间控制广告轮播时间，默认轮播时间为30秒。

```objective-c

#import "DemoBannerViewController.h"
#import "ViewBuilder.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoBannerViewController () <AdvanceBannerDelegate>
@property (nonatomic, strong) AdvanceBanner *advanceBanner;
@property (nonatomic, strong) UIView *contentV;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"Banner", @"adspotId": @"10033-200031"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    if (!_contentV) {
        _contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/6.4)];
    }
    [self.adShowView addSubview:self.contentV];
    self.adShowView.hidden = NO;
    
    self.advanceBanner = [[AdvanceBanner alloc] initWithMediaId:self.mediaId adspotId:self.adspotId adContainer:self.contentV viewController:self];
    self.advanceBanner.delegate = self;
    [self.advanceBanner setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotId:@"10000558"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkId:SDK_ID_MERCURY];
    [self.advanceBanner loadAd];
}

// MARK: ======================= AdvanceBannerDelegate =======================
/// 广告数据拉取成功回调
- (void)advanceBannerOnAdReceived {
    [DemoUtils showToast:@"广告数据拉取成功回调"];
}

/// banner条曝光回调
- (void)advanceBannerOnAdShow {
    [DemoUtils showToast:@"广告曝光回调"];
}

/// 广告渲染失败
- (void)advanceBannerOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告点击回调
- (void)advanceBannerOnAdClicked {
    [DemoUtils showToast:@"广告点击回调"];
}

/// 请求广告数据失败后调用
- (void)advanceBannerOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    [DemoUtils showToast:@"请求广告数据失败后调用"];
}

/// 广告关闭回调
- (void)advanceBannerOnAdClosed {
    [DemoUtils showToast:@"广告关闭回调"];
}

@end

```



### 插屏广告

插屏广告分为两个阶段，加载和展示。需要在广告加载成功后调用展示方法展示插屏广告。

```objective-c

#import "DemoInterstitialViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoInterstitialViewController () <AdvanceInterstitialDelegate>
@property (nonatomic, strong) AdvanceInterstitial *advanceInterstitial;

@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200043"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithMediaId:self.mediaId
                                                                   adspotId:self.adspotId
                                                             viewController:self];
    self.advanceInterstitial.delegate=self;
    [self.advanceInterstitial setDefaultSdkSupplierWithMediaId:@"100255"
                                                      adspotId:@"10000559"
                                                      mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkId:SDK_ID_MERCURY];
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceInterstitial showAd];
}

// MARK: ======================= AdvanceInterstitialDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceInterstitialOnAdReceived {
    [DemoUtils showToast:@"请求广告数据成功后调用"];
}

/// 广告准备就绪
- (void)advanceInterstitialOnAdReady {
    [DemoUtils showToast:@"广告准备就绪"];
}

/// 广告渲染失败
- (void)advanceInterstitialOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

/// 广告曝光成功
- (void)advanceInterstitialOnAdShow {
    [DemoUtils showToast:@"广告曝光成功"];
}

/// 广告点击
- (void)advanceInterstitialOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

/// 广告拉取失败
- (void)advanceInterstitialOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    [DemoUtils showToast:@"广告拉取失败"];
}

/// 广告关闭
- (void)advanceInterstitialOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}

@end

```



### 原生模板

原生模板广告分为几个阶段:加载广告获得模板view，渲染广告模板，展示广告模板，需要注意的是，媒体需要持有SDK返回的view数组，否则view会自动释放，无法渲染成功。用户点击关闭按钮后，开发者需要从数组和视图中把关闭回调的view删除。

```objective-c

#import "FeedExpressViewController.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"

#import "DemoUtils.h"
#import <AdvanceSDK/AdvanceSDK.h>

@interface FeedExpressViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;

@property(strong,nonatomic) AdvanceNativeExpress *advanceFeed;
@property (nonatomic, strong) NSMutableArray *dataArrM;

@end

@implementation FeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"信息流";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"splitnativeexpresscell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [_tableView registerClass:[ExamTableViewCell class] forCellReuseIdentifier:@"ExamTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    
    [self loadBtnAction:nil];
}

- (void)loadBtnAction:(id)sender {
    _dataArrM = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithMediaId:self.mediaId adspotId:self.adspotId viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 300)];
    
    _advanceFeed.delegate = self;
    [_advanceFeed setDefaultSdkSupplierWithMediaId:@"100255"
                                          adspotId:@"10002698"
                                          mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                            sdkId:SDK_ID_MERCURY];
    [_advanceFeed loadAd];
}

// MARK: ======================= AdvanceNativeExpressDelegate =======================
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(NSArray<UIView *> *)views {
    NSLog(@"拉取数据成功 ");
    for (NSInteger i=0; i<views.count;i++) {
        [views[i] performSelector:@selector(render)];
        [_dataArrM insertObject:views[i] atIndex:1];
        [self.tableView reloadData];
    }
}

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(UIView *)adView {
    NSLog(@"广告曝光");
}

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(UIView *)adView {
    NSLog(@"广告点击");
}

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(UIView *)adView {
    [self.tableView reloadData];
}

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(UIView *)adView {
    NSLog(@"广告渲染失败");
}

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(UIView *)adView {
    //需要从tableview中删除
    NSLog(@"广告关闭");
    [_dataArrM removeObject: adView];
    [adView removeFromSuperview];
    [self.tableView reloadData];
}

/// 广告数据拉取失败
- (void)advanceNativeExpressOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error {
    NSLog(@"广告拉取失败");
}

// MARK: ======================= UITableViewDelegate, UITableViewDataSource =======================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _expressAdViews.count*2;
//    return 2;
    return _dataArrM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return ((BYExamCellModelElement *)_dataArrM[indexPath.row]).cellh;
    } else {
        return ((UIView *)_dataArrM[indexPath.row]).bounds.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([_dataArrM[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExamTableViewCell"];
        ((ExamTableViewCell *)cell).item = _dataArrM[indexPath.row];
        return cell;
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
        if ([subView superview]) {
            [subView removeFromSuperview];
        }
        UIView *view = _dataArrM[indexPath.row];
        view.tag = 1000;
        [cell.contentView addSubview:view];
        cell.accessibilityIdentifier = @"nativeTemp_ad";
        return cell;
    }
}

@end

```



### 激励视频

激励视频分为广告数据加载，视频缓存，以及展示阶段，当视频缓存成功回调后可以调用展示方法展示激励视频，激励视频在展示的过程中无法被关闭。

```objective-c

#import "DemoRewardVideoViewController.h"
#import "DemoUtils.h"
#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoRewardVideoViewController () <AdvanceRewardVideoDelegate>
@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
@end

@implementation DemoRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"激励视频", @"adspotId": @"10033-200045"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithMediaId:self.mediaId
                                                                 adspotId:self.adspotId
                                                           viewController:self];
    self.advanceRewardVideo.delegate=self;
    [self.advanceRewardVideo setDefaultSdkSupplierWithMediaId:@"100255"
                                                     adspotId:@"10002595"
                                                     mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                       sdkId:SDK_ID_MERCURY];
    [self.advanceRewardVideo loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceRewardVideo showAd];
}

// MARK: ======================= AdvanceRewardVideoDelegate =======================
- (void)advanceRewardVideoOnAdReady {
    [DemoUtils showToast:@"广告数据加载成功"];
}

- (void)advanceRewardVideoOnAdVideoCached
{
    [DemoUtils showToast:@"视频缓存成功"];
}

- (void)advanceRewardVideoAdDidRewardEffective {
    [DemoUtils showToast:@"到达激励时间"];
}

- (void)advanceRewardVideoOnAdRenderFailed {
    [DemoUtils showToast:@"广告渲染失败"];
}

- (void)advanceRewardVideoOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

- (void)advanceRewardVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    [DemoUtils showToast:@"广告拉取失败"];
}

- (void)advanceRewardVideoOnAdShow {
    [DemoUtils showToast:@"广告展示"];
}

- (void)advanceRewardVideoOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}

- (void)advanceRewardVideoAdDidPlayFinish {
    [DemoUtils showToast:@"播放完成"];
}

@end


```

### 全屏视频视频
全屏视频视频分为广告数据加载，视频缓存，以及展示阶段，当视频缓存成功回调后可以调用展示方法展示激励视频，激励视频在展示的过程可以被关闭。

```objective-c
#import "AdvanceSDK.h"

@interface DemoFullScreenVideoController () <AdvanceFullScreenVideoDelegate>
@property (nonatomic, strong) AdvanceFullScreenVideo *advanceFullScreenVideo;

@end

@implementation DemoFullScreenVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200076"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceFullScreenVideo = [[AdvanceFullScreenVideo alloc] initWithMediaId:self.mediaId
                                                                   adspotId:self.adspotId
                                                             viewController:self];
    self.advanceFullScreenVideo.delegate = self;
    [self.advanceFullScreenVideo setDefaultSdkSupplierWithMediaId:@"100255"
                                                      adspotId:@"10000559"
                                                      mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkId:SDK_ID_MERCURY];
    [self.advanceFullScreenVideo loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceFullScreenVideo showAd];
}

// MARK: ======================= AdvanceFullScreenVideoDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceFullScreenVideoOnAdReceived {
    NSLog(@"请求广告数据成功后调用");
}

/// 广告渲染失败
- (void)advanceFullScreenVideoOnAdRenderFailed {
    NSLog(@"广告渲染失败");
}

/// 广告曝光成功
- (void)advanceFullScreenVideoOnAdShow {
    NSLog(@"广告曝光成功");
}

/// 广告点击
- (void)advanceFullScreenVideoOnAdClicked {
    NSLog(@"广告点击");
}

/// 广告拉取失败
- (void)advanceFullScreenVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告拉取失败");
}

/// 广告关闭
- (void)advanceFullScreenVideoOnAdClosed {
    NSLog(@"广告关闭");
}

/// 广告播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish {
    NSLog(@"广告播放完成");
}

@end

```

## 自定义广告位接入开发

如果默认广告位实现不符合要求，或者您需要支持其他SDK的广告，可以采用自定义开发的方式接入策略管理。

导入头文件，实现`AdvanceBaseAdspotDelegate`代理

```Objective-C
#import <AdvanceSDK/AdvanceSDK.h>

@interface CustomSplashViewController () <AdvanceBaseAdspotDelegate>
@property (nonatomic, strong) AdvanceBaseAdspot *adspot;
@end

```

初始化广告管理对象并实现代理方法`_adspot.supplierDelegate`，开发者需要在`advanceBaseAdspotWithSdkId: params:`中根据返回的渠道Id，自行处理渠道的初始化。

```Objective-C
- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    _adspot = [[AdvanceBaseAdspot alloc] initWithMediaId:self.mediaId adspotId:self.adspotId];
    [_adspot setDefaultSdkSupplierWithMediaId:@"100255"
                                adspotId:@"10002436"
                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                  sdkId:SDK_ID_MERCURY];
    _adspot.supplierDelegate = self;
    [_adspot loadAd];
}

// MARK: ======================= AdvanceBaseAdspotDelegate =======================
/// 加载渠道广告，将会返回渠道所需参数
/// @param sdkId 渠道Id
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkId:(NSString *)sdkId params:(NSDictionary *)params {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // 根据渠道id自定义初始化
    if ([sdkId isEqualToString:SDK_ID_GDT]) {
        _gdt_ad = [[GDTSplashAd alloc] initWithAppId:[params objectForKey:@"mediaid"]
                                         placementId:[params objectForKey:@"adspotid"]];
        _gdt_ad.delegate = self;
        _gdt_ad.fetchDelay = 5;
        [_gdt_ad loadAdAndShowInWindow:window];
    } else if ([sdkId isEqualToString:SDK_ID_CSJ]) {
        _csj_ad = [[BUNativeExpressSplashView alloc] initWithSlotID:[params objectForKey:@"adspotid"]
                                                             adSize:[UIScreen mainScreen].bounds.size
                                                 rootViewController:self];
        _csj_ad.delegate = self;
        _csj_ad.tolerateTimeout = 3;
        [_csj_ad loadAdData];
        [window addSubview:_csj_ad];
    } else if ([sdkId isEqualToString:SDK_ID_MERCURY]) {
        _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:[params objectForKey:@"adspotid"]
                                                         delegate:self];
        _mercury_ad.controller = self;
        [_mercury_ad loadAdAndShow];
    }
}

/// @param sdkId 渠道Id
/// @param error 失败原因
- (void)advanceBaseAdspotWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"%@", error);
}

```

**事件上报**
> 事件上报必须在对应事件回调方法中执行

使用`[_adspot reportWithType:事件上报类型];`进行事件上报，需手动调用的上报有4种:

1. AdvanceSdkSupplierRepoSucceeded（广告拉取成功）
2. AdvanceSdkSupplierRepoImped（广告曝光）
3. AdvanceSdkSupplierRepoFaileded（广告拉取失败）
4. AdvanceSdkSupplierRepoClicked（广告被点击）

**注意**：在失败上报的方法中同时需要手动执行策略切换方法，此方法会在某渠道广告拉取失败后快速选择下一个渠道广告

```
[_adspot selectSdkSupplierWithError:error];
```

具体实现可参照Example工程。

## 验收测试

代码对接完成后请提供测试包给我方对接测试人员进行验收。
