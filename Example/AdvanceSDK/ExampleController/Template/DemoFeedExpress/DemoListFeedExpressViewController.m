//
//  DemoListFeedExpressViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/21.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoListFeedExpressViewController.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"

#import "DemoUtils.h"
#import <AdvanceSDK/AdvanceNativeExpress.h>

@interface DemoListFeedExpressViewController () <UITableViewDelegate, UITableViewDataSource, AdvanceNativeExpressDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property(strong,nonatomic) AdvanceNativeExpress *advanceFeed;
@property (nonatomic, strong) NSMutableArray *dataArrM;
@property (nonatomic, strong) NSMutableArray *arrViewsM;

@end

@implementation DemoListFeedExpressViewController

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
//    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:@"11111112" viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 300)];
//    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 300)];
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId customExt:self.ext viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 0)];

    _advanceFeed.delegate = self;
    [_advanceFeed loadAd];
}

// MARK: ======================= AdvanceNativeExpressDelegate =======================
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(NSArray<UIView *> *)views {
    NSLog(@"拉取数据成功  %@",views);
    self.arrViewsM = [views mutableCopy];
    for (NSInteger i=0; i<self.arrViewsM.count;i++) {
        if ([self.arrViewsM[i] isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")] ||
            [self.arrViewsM[i] isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")]) {
            [self.arrViewsM[i] performSelector:@selector(setRootViewController:) withObject:self];
            [self.arrViewsM[i] performSelector:@selector(render)];
        } else if ([self.arrViewsM[i] isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
            [self.arrViewsM[i] performSelector:@selector(setController:) withObject:self];
            [self.arrViewsM[i] performSelector:@selector(render)];
        } else if ([self.arrViewsM[i] isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {// 广点通旧版信息流
            [self.arrViewsM[i] performSelector:@selector(setController:) withObject:self];
            [self.arrViewsM[i] performSelector:@selector(render)];
        } else if ([self.arrViewsM[i] isKindOfClass:NSClassFromString(@"GDTNativeExpressProAdView")]) {// 广点通新版信息流
            [self.arrViewsM[i] performSelector:@selector(setController:) withObject:self];
            [self.arrViewsM[i] performSelector:@selector(render)];
        }
        
        
        [_dataArrM insertObject:self.arrViewsM[i] atIndex:1];
    }
    [self.tableView reloadData];
}

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(UIView *)adView {
    NSLog(@"广告曝光 %s", __func__);
}

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(UIView *)adView {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告渲染成功
/// 注意和广告数据拉取成功的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)advanceNativeExpressOnAdRenderSuccess:(UIView *)adView {
    NSLog(@"广告渲染成功 %s %@", __func__, adView);
    [self.tableView reloadData];
}

/// 广告渲染失败
/// 注意和广告加载失败的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)advanceNativeExpressOnAdRenderFail:(UIView *)adView {
    NSLog(@"广告渲染失败 %s %@", __func__, adView);
    [_dataArrM removeObject: adView];
    [adView removeFromSuperview];
    [self.tableView reloadData];
}

/// 广告加载失败
/// 该回调只会触发一次
- (void)advanceFailedWithError:(NSError *)error {
    NSLog(@"广告展示失败 %s  error: %@", __func__, error);

}

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);

}

/// 加载策略成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(UIView *)adView {
    //需要从tableview中删除
    NSLog(@"广告关闭 %s", __func__);
    [_dataArrM removeObject: adView];
    [adView removeFromSuperview];
    [self.tableView reloadData];
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


