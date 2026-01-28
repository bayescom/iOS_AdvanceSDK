//
//  DemoListFeedExpressViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/21.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoListFeedExpressViewController.h"
#import "JDStatusBarNotification.h"
#import "CellBuilder.h"
#import "BYExamCellModel.h"
#import <AdvanceSDK/AdvanceNativeExpress.h>

@interface DemoListFeedExpressViewController () <UITableViewDelegate, UITableViewDataSource, AdvanceNativeExpressDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property(strong,nonatomic) AdvanceNativeExpress *nativeExpressAd;
@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation DemoListFeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"模板渲染信息流";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kkScreenWidth, kkScreenHeight - kkNavigationBarHeight) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [_tableView registerClass:[ExamTableViewCell class] forCellReuseIdentifier:@"ExamTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self loadAd];
}

- (void)loadAd {
    _arrayData = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    // adSize 高度设置0自适应
    _nativeExpressAd = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId extra:self.ext delegate:self];
    _nativeExpressAd.adSize = CGSizeMake(self.view.bounds.size.width, 0);
    _nativeExpressAd.viewController = self;
    [_nativeExpressAd loadAd];
}

#pragma mark: - AdvanceNativeExpressDelegate
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

#pragma mark: - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_arrayData[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        return ((BYExamCellModelElement *)_arrayData[indexPath.row]).cellh;
    } else {
        AdvNativeExpressAdWrapper *nativeAdWrapper = _arrayData[indexPath.row];
        UIView *view = nativeAdWrapper.expressView;
        return view.frame.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([_arrayData[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ExamTableViewCell"];
        ((ExamTableViewCell *)cell).item = _arrayData[indexPath.row];
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

- (void)dealloc {
    
}

@end


