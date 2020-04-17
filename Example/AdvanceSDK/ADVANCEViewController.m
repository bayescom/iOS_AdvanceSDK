//
//  ADVANCEViewController.m
//  AdvanceSDK
//
//  Created by Cheng455153666 on 02/27/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "ADVANCEViewController.h"

@interface ADVANCEViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *dataArr;

@property (nonatomic, strong) UIImageView *logoImgV;
@end

@implementation ADVANCEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubviews];
    
    _dataArr = @[
        @{@"title":@"开屏广告", @"targetVCName": @"DemoSplashViewController"},
        @{@"title":@"Banner", @"targetVCName": @"DemoBannerViewController"},
        @{@"title":@"插屏广告", @"targetVCName": @"DemoInterstitialViewController"},
        @{@"title":@"激励视频", @"targetVCName": @"DemoRewardVideoViewController"},
        @{@"title":@"信息流", @"targetVCName": @"BYFeedExpressViewController"},
    ];
    
    [_tableView reloadData];
}

- (void)initSubviews {
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithTitle:@"SDK设置" style:UIBarButtonItemStylePlain target:self action:@selector(toSettingsViewController)];
    self.navigationItem.rightBarButtonItem = settingItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    _tableView.backgroundView = [UIView new];
    
    UIImageView *bgImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo"]];
    bgImgV.contentMode = UIViewContentModeScaleAspectFit;
    [_tableView.backgroundView addSubview:bgImgV];
    
    UILabel *vLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    vLbl.textAlignment = NSTextAlignmentCenter;
    
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64);
}

- (void)toSettingsViewController {
    [self.navigationController pushViewController:[[NSClassFromString(@"SettingsViewController") alloc] init] animated:YES];
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
