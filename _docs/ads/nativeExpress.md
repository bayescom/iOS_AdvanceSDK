# iOS 原生模板信息流广告

**素材类型：图片、视频 || 常见尺寸： 16:9、9:16**
***
<font color=#757575 size=2>**简介：** 平台模板包含多种广告场景：动态信息流/横幅/贴片,在应用的内容流中与应用内容穿插展示</font>

## 1.广告位代理方法及属性说明

| 属性| 	介绍|
|--------- |---------------|  
| adSize | 广告的尺寸<br>**注意:** 该尺寸务必与相应渠道后台的设置的尺寸相符,不然会影响曝光率| 


| 代理方法| 	介绍|
|--------- |---------------|  
|- didFinishLoadingADPolicyWithSpotId: | 广告策略服务加载成功 |  
|- didFailLoadingADSourceWithSpotId: error: description: | 广告策略或者渠道广告加载失败 |  
|- didStartLoadingADSourceWithSpotId: sourceId: | 广告位中某一个广告源开始加载广告<br> sourceId :将要加载的渠道id|  
|- didFinishLoadingNativeExpressAds: spotId:|信息流广告数据拉取成功|
|- nativeExpressAdViewRenderSuccess: spotId: extra: |广告曝光的回调|
|- nativeExpressAdViewRenderFail: spotId: extra: |广告被点击的回调|
|- didShowNativeExpressAd: spotId: extra: |广告渲染成功的回调|
|- didClickNativeExpressAd: spotId: extra: |广告渲染失败的回调|
|- didCloseNativeExpressAd: spotId: extra:|广告被关闭的回调|

***

## 2.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 原生模板信息流广告类为AdvanceNativeExpress</font></span>
- 原生模板广告分为几个阶段:加载广告获得模板对象，渲染广告模板，展示广告模板，需要注意的是，开发者需要在当前页面持有SDK返回的NativeAd对象，否则该对象会自动释放，无法渲染成功。用户点击关闭按钮后，开发者需要从数组和视图中把关闭的NativeAd对象移除。
- 集成期间可先使用预先配置好的Demo广告位ID进行集成，[查看详情](advance/ios/faq/test.md)

#### 加载并展示广告
```
- (void)viewDidLoad {
    _arrayData = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
}

- (void)loadAd {
    // adSize 高度设置0自适应
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId customExt:self.ext viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 0)];
    _advanceFeed.delegate = self;
    [_advanceFeed loadAd];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_arrayData[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return 44;
    } else {
        AdvanceNativeExpressAd *nativeAd = _arrayData[indexPath.row];
        UIView *view = [nativeAd expressView];
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
        AdvanceNativeExpressAd *nativeAd = _arrayData[indexPath.row];
        UIView *view = [nativeAd expressView];
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
/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 信息流广告数据拉取成功后，聚合内部会执行渲染操作
- (void)didFinishLoadingNativeExpressAds:(NSArray<AdvanceNativeExpressAd *> *)nativeAds spotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
}

/// 信息流广告渲染成功
/// 该回调可能会触发多次
/// eg: 广点通拉取广告成功并返回一组view，其中某个view渲染成功
- (void)nativeExpressAdViewRenderSuccess:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告渲染成功 %s %@", __func__, nativeAd);
    [_arrayData insertObject:nativeAd atIndex:1];
    [self.tableView reloadData];
}

/// 信息流广告渲染失败
/// 该回调可能会触发多次
/// eg: 广点通拉取广告成功并返回一组view，其中某个view渲染失败
- (void)nativeExpressAdViewRenderFail:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告渲染失败 %s %@", __func__, nativeAd);
}

/// 信息流广告曝光
-(void)didShowNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光 %s", __func__);
}

/// 信息流广告点击
-(void)didClickNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 信息流广告关闭
-(void)didCloseNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    //需要从tableview中删除
    NSLog(@"广告关闭 %s", __func__);
    [_arrayData removeObject: nativeAd];
    [self.tableView reloadData];
    self.advanceFeed = nil;
}
```

