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
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId customExt:self.ext viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 300)];

    _advanceFeed.delegate = self;
    [_advanceFeed setDefaultAdvSupplierWithMediaId:@"100255"
                                          adspotId:@"10002698"
                                          mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                            sdkId:SDK_ID_MERCURY];
    [_advanceFeed loadAd];
}

// MARK: ======================= AdvanceNativeExpressDelegate =======================
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(NSArray<UIView *> *)views {
    NSLog(@"拉取数据成功  %@",views);
    for (NSInteger i=0; i<views.count;i++) {
        if ([views[i] isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")] ||
            [views[i] isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")]) {
            [views[i] performSelector:@selector(setRootViewController:) withObject:self];
            [views[i] performSelector:@selector(render)];
        } else if ([views[i] isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
            [views[i] performSelector:@selector(setController:) withObject:self];
            [views[i] performSelector:@selector(render)];
        } else if ([views[i] isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {// 广点通旧版信息流
            [views[i] performSelector:@selector(setController:) withObject:self];
            [views[i] performSelector:@selector(render)];
        } else if ([views[i] isKindOfClass:NSClassFromString(@"GDTNativeExpressProAdView")]) {// 广点通新版信息流
            [views[i] performSelector:@selector(setController:) withObject:self];
            [views[i] performSelector:@selector(render)];
        }
        
        
        [_dataArrM insertObject:views[i] atIndex:1];
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
- (void)advanceNativeExpressOnAdRenderSuccess:(UIView *)adView {
    NSLog(@"广告渲染成功 %s", __func__);
    [self.tableView reloadData];
}

/// 广告加载失败
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


