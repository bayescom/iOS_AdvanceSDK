# iOS 激励视频广告

**素材类型：一图一视频 || 常见尺寸： 9:16、2:1**
***
<font color=#757575 size=2>**简介：** 激励视频广告是指将短视频融入到app的业务场景当中，成为app“任务”之一，用户观看短视频广告后可以得到一些应用内奖励</font>



## 1.广告位属性及方法说明

| 属性           | 	介绍            |
|--------------------|---------------------------------|  
| isAdValid          | 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败 | 
| rewardedVideoModel | 用户信息、奖励信息对象                     |

| 方法                     | 	介绍    |                                                                                          
|----------------|---------------------------| 
| - initWithAdspotId: customExt: | 广告位初始化方法<br>adspotid: 广告位id <br>customExt: 自定义拓展参数（可为空）| 
| - loadAd                                       | 加载广告   |                                                                                                    
| - showAdFromViewController:                    | 展示广告   |                                                          

| 代理方法          | 	介绍              |
|---------------------|---------------------------|  
| - didFinishLoadingADPolicyWithSpotId:                        | 广告策略服务加载成功                               |  
| - didFailLoadingADSourceWithSpotId: error: description:      | 广告策略或者渠道广告加载失败                           |  
| - didStartLoadingADSourceWithSpotId: sourceId:               | 广告位中某一个广告源开始加载广告<br> sourceId :将要加载的渠道id |  
| - didFinishLoadingRewardedVideoADWithSpotId:                 | 激励视频广告数据拉取成功                             |
| - rewardedVideoDidDownLoadForSpotId: extra:                  | 激励视频缓存成功                                 |
| - rewardedVideoDidStartPlayingForSpotId: extra:              | 激励视频开始播放                                 |
| - rewardedVideoDidEndPlayingForSpotId: extra:                | 激励视频播放完成                                 |
| - rewardedVideoDidClickForSpotId: extra:                     | 激励视频广告被点击                                |
| - rewardedVideoDidCloseForSpotId: extra:                     | 激励视频广告被关闭                                |
| - rewardedVideoDidRewardSuccessForSpotId: extra: rewardInfo: | 激励视频广告激励成功                               |
| - rewardedVideoServerRewardDidFailForSpotId: extra: error:   | 服务端验证激励失败                                |
***

## 2.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 激励视频广告类为AdvanceReward</font></span>
- 激励视频分为广告数据加载，视频缓存，以及展示阶段，当视频缓存成功回调后可以调用展示方法展示激励视频。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载广告
```
- (void)loadAd {
    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:self.adspotId
                                                                 customExt:self.ext];
    self.advanceRewardVideo.delegate = self;
    
    // 奖励设置（可选）
    AdvRewardedVideoModel *model = [[AdvRewardedVideoModel alloc] init];
    model.userId = @"123456";
    model.rewardAmount = 100;
    model.rewardName = @"福利";
//    model.extra = @{@"key1" : @"value1"}.modelToJSONString; // 透传参数
    self.advanceRewardVideo.rewardedVideoModel = model;
    // 加载广告
    [self.advanceRewardVideo loadAd];
}
```

#### 展示广告
```
- (void)showAd {
    if (self.advanceRewardVideo.isAdValid) {
        [self.advanceRewardVideo showAdFromViewController:self];
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
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error,description);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
    self.advanceRewardVideo.delegate = nil;
    self.advanceRewardVideo = nil;
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 激励视频广告数据拉取成功
- (void)didFinishLoadingRewardedVideoADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功, 正在缓存... %s", __func__);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
}

/// 激励视频缓存成功
- (void)rewardedVideoDidDownLoadForSpotId:(NSString *)spotId extra:(NSDictionary *)extra{
    NSLog(@"视频缓存成功 %s", __func__);
}

/// 激励视频开始播放
- (void)rewardedVideoDidStartPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 激励视频到达激励时间
- (void)rewardedVideoDidRewardSuccessForSpotId:(NSString *)spotId extra:(NSDictionary *)extra rewardInfo:(AdvRewardCallbackInfo *)rewardInfo {
    NSLog(@"到达激励时间 %s %@", __func__, rewardInfo);
}

/// 服务端验证激励失败
- (void)rewardedVideoServerRewardDidFailForSpotId:(NSString *)spotId extra:(NSDictionary *)extra error:(NSError *)error {
    NSLog(@"服务端验证激励失败 %s %@", __func__, error);
}

/// 激励视频播放完成
- (void)rewardedVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"播放完成 %s", __func__);
}

/// 激励视频广告点击
- (void)rewardedVideoDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 激励视频广告关闭
- (void)rewardedVideoDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
    self.advanceRewardVideo.delegate = nil;
    self.advanceRewardVideo = nil;
}
```

## 3.服务端激励验证说明
为满足开发者对激励视频奖励发放加强校验的需求，Advance为开发者提供服务端回调功能，开发者可依照此文档进行相关配置，基于此功能开发者可在服务端对观看激励视频用户是否发放奖励进行二次校验。

### 3.1 使用Advance聚合服务端激励配置

在倍联后台，创建**聚合**激励视频广告位时，需选中**服务端激励回调**，填入回调地址信息，同时广告平台的激励id需要选中**客户端回调**方式，以避免多次发起服务端验证。

开发者在代码中通过聚合SDK的API 传入UserID(用户唯一ID)和用户自定义数据，这些参数最终将通过回调URL 回传给开发者 （参考第二部分代码示例）

当客户端播放激励视频广告，触发激励发放时，首先由广告SDK通过客户端回调方式回调激励达成事件，聚合SDK收到激励达成事件后，会通过Advance服务器请求开发者配置在**倍联后台的服务端激励回调url**（APP服务端和Advance服务端之间的具体交互说明可参考 3.2 中内容），拿到结果后再通过`- rewardedVideoDidRewardSuccessForSpotId: extra: rewardInfo:`或者`- rewardedVideoServerRewardDidFailForSpotId: extra: error:` 回调形式告诉开发者。


* AdvRewardCallbackInfo 信息内容详解

| 成员 | 类型 | 含义
|:------------- |:--------------- |:---------------|  
| sourceId | String |SDK渠道id
|rewardAmount | int | 激励数量
|rewardName | String |激励名称

### 3.2 APP服务端接收Advance服务器回调说明

1）开发者需选择了**Advance聚合服务端激励**方式，并设置开发者服务端激励的回调URL，如下图所示：

![聚合服务端激励配置](../../common/image/advance_reward_callback_setting.jpg)

2）Advance服务器会将通过**GET**方式请求开发者的回调URL，并同时拼接携带以下参数在url链接中

| 字段名称           | 数据类型         | 用途说明                                                    |
|----------------|--------------|---------------------------------------------------------|
| secret         | String       | 广告位和秘钥的签名，开发者用于验证回调的正确性                                 |
| timestamp      | Long         | 当前时间戳                                                   |
| user_id        | String       | 用户id，由开发者通过Advance SDK API设置                            |
| extra          | String       | 用户业务参数, 由开发者通过Advance SDK API设置                         |
| reward_amount  | int          | 激励数量，开发者传入或后台配置                                         |
| reward_name    | String       | 激励名称，开发者传入或后台配置                                         |
| trans_id       | String       | 聚合SDK生成唯一id标识，等效于reqid，（开发者通过广告位实例调用`getAdvanceId()`获取） |
| placement_id   | String       | advance聚合广告位id                                          |
| adn_channel_id | String       | 广告SDK平台id标识                                             |
| adn_adspot_id  | String       | 广告SDK平台得广告位id                                           |

3）签名验证说明

开发者需要使用以下规则对回调参数进行签名验证，确保回调的正确性。
使用请求的广告位id和系统中的秘钥进行签名，签名规则如下：广告位id、secret、timestamp拼接成的字符串进行MD5加密，生成32位小写字符串。

例如：

广告位id为：10001000
秘钥为：1234567890abcdef
时间戳：1761212009000
签名结果是：e2c13093a71a09cf0821c161282534cc

4）验证结果约定

开发者回调URL收到Advance的服务端激励回调后，需给服务器返回**success**或者**fail**，表示激励验证结果。 Advance的服务端收到success或者fail后，将不会重发服务端激励回调。
Advance服务器发起服务端激励回调后2秒内无响应则视为超时，超时后会每隔一会（比如2秒，4秒）重试发送激励回调。最大重试3次还超时，则不再向开发者回调URL发起激励回调。