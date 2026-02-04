# iOS 原生模板信息流广告

**素材类型：图片、视频 || 常见尺寸： 16:9、9:16**
***
<font color=#757575 size=2>**简介：** 平台模板包含多种广告场景：动态信息流/横幅/贴片,在应用的内容流中与应用内容穿插展示</font>

## 1.广告位接口说明
| 属性| 	介绍|
|--------- |---------------|  
|adSize |广告位尺寸| 
|viewController |用于广告跳转的视图控制器| 
|muted |设定是否静音播放视频，默认为YES| 

| 方法| 	介绍|
|--------- |---------------| 
|- initWithAdspotId: extra: delegate: |广告位初始化方法<br>adspotid: 广告位id <br>extra: 自定义扩展参数（可为空）<br>delegate: 广告代理对象| 
|- loadAd |加载广告| 

## 2.广告对象说明
| 广告包装类信息| 	介绍|
|--------- |---------------|  
|AdvNativeExpressAdWrapper |用户通过回调获取的广告包装类信息：<br>包含信息流视图对象、渠道标识等| 

## 3.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
|- onNativeExpressAdSuccessToLoad: | 广告加载成功回调 |  
|- onNativeExpressAdFailToLoad: error: | 广告加载失败回调 |  
|- onNativeExpressAdViewRenderSuccess: | 广告渲染成功回调 |  
|- onNativeExpressAdViewRenderFail: error: | 广告渲染失败回调 |  
|- onNativeExpressAdViewExposured: | 广告曝光回调|  
|- onNativeExpressAdViewClicked: |广告点击回调|
|- onNativeExpressAdViewClosed: |广告关闭回调|

## 4.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 原生模板信息流广告类为AdvanceNativeExpress</font></span>
- 原生模板广告分为几个阶段:加载广告获得模板对象，渲染广告模板，展示广告模板，需要注意的是，开发者需要在当前页面持有广告位AdvanceNativeExpress对象，否则该对象会自动释放，无法渲染成功。用户点击关闭按钮后，开发者需要从数组和视图中把关闭的nativeAdWrapper对象移除。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载并展示广告
```
- (void)viewDidLoad {
    _arrayData = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
}

- (void)loadAd {
    // adSize 高度设置0自适应
    _nativeExpressAd = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId extra:self.ext delegate:self];
    _nativeExpressAd.adSize = CGSizeMake(self.view.bounds.size.width, 0);
    _nativeExpressAd.viewController = self;
    [_nativeExpressAd loadAd];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_arrayData[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return 44;
    } else {
        AdvNativeExpressAdWrapper *nativeAdWrapper = _arrayData[indexPath.row];
        UIView *view = nativeAdWrapper.expressView;
        return view.frame.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([_arrayData[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        ......
        return cell;
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
        if ([subView superview]) {
            [subView removeFromSuperview];
        }
        AdvNativeExpressAdWrapper *nativeAdWrapper = _arrayData[indexPath.row];
        UIView *view = nativeAdWrapper.expressView;
        view.tag = 1000;
        [cell.contentView addSubview:view];
        CGRect frame = view.frame;
        frame.origin.x = (cell.contentView.bounds.size.width - frame.size.width) / 2;
        view.frame = frame;
        cell.accessibilityIdentifier = @"nativeTemp_ad";
        return cell;
    }
}
```

#### 广告回调

```
/// 广告加载成功回调
- (void)onNativeExpressAdSuccessToLoad:(AdvanceNativeExpress *)nativeExpressAd {
    NSLog(@"模板信息流广告加载成功 %s %@", __func__, nativeExpressAd);
}

/// 广告加载失败回调
-(void)onNativeExpressAdFailToLoad:(AdvanceNativeExpress *)nativeExpressAd error:(NSError *)error {
    NSLog(@"模板信息流广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.nativeExpressAd = nil;
}

/// 广告渲染成功
- (void)onNativeExpressAdViewRenderSuccess:(AdvNativeExpressAdWrapper *)nativeAdWrapper {
    NSLog(@"模板信息流广告渲染成功 %s %@", __func__, nativeAdWrapper);
    [_arrayData insertObject:nativeAdWrapper atIndex:1];
    [self.tableView reloadData];
}

/// 广告渲染失败
- (void)onNativeExpressAdViewRenderFail:(AdvNativeExpressAdWrapper *)nativeAdWrapper error:(NSError *)error {
    NSLog(@"模板信息流广告渲染失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告渲染失败" dismissAfter:0.7];
    self.nativeExpressAd = nil;
}

/// 广告曝光回调
-(void)onNativeExpressAdViewExposured:(AdvNativeExpressAdWrapper *)nativeAdWrapper {
    NSLog(@"模板信息流广告曝光回调 %s %@", __func__, nativeAdWrapper);
}

/// 广告点击回调
- (void)onNativeExpressAdViewClicked:(AdvNativeExpressAdWrapper *)nativeAdWrapper {
    NSLog(@"模板信息流广告点击回调 %s %@", __func__, nativeAdWrapper);
}

/// 广告关闭回调
- (void)onNativeExpressAdViewClosed:(AdvNativeExpressAdWrapper *)nativeAdWrapper {
    NSLog(@"模板信息流广告关闭回调 %s %@", __func__, nativeAdWrapper);
    [_arrayData removeObject:nativeAdWrapper];
    [self.tableView reloadData];
    self.nativeExpressAd = nil;
}
```

