//
//  ViewController.m
//  AdvanceSDK
//
//  Created by Bayes on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *dataArr;
@property (nonatomic, strong) UIImageView *logoImgV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聚合广告位";
    
    [self initSubviews];
    
    _dataArr = @[
        @{@"title":@"开屏", @"targetVCName": @"DemoSplashViewController"},
        @{@"title":@"Banner", @"targetVCName": @"DemoBannerViewController"},
        @{@"title":@"插屏", @"targetVCName": @"DemoInterstitialViewController"},
        @{@"title":@"激励视频", @"targetVCName": @"DemoRewardVideoViewController"},
        @{@"title":@"全屏视频", @"targetVCName": @"DemoFullScreenVideoController"},
        @{@"title":@"模版渲染信息流", @"targetVCName": @"DemoFeedExpressViewController"},
        @{@"title":@"自渲染信息流", @"targetVCName": @"DemoRenderFeedViewController"},
    ];
    
    [_tableView reloadData];
}

- (void)initSubviews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kkScreenWidth, kkScreenHeight - kkNavigationBarHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

// MARK: UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid"];
    }
    cell.textLabel.text = _dataArr[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[NSClassFromString(_dataArr[indexPath.row][@"targetVCName"]) alloc] init];
    vc.title = _dataArr[indexPath.row][@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


@end
