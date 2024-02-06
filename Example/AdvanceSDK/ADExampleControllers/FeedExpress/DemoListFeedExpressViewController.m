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
#import <AdvanceSDK/AdvSdkConfig.h>
#import <AdvanceSDK/AdvanceNativeExpress.h>
#import <AdvanceSDK/AdvanceNativeExpressAd.h>
#import "Masonry.h"

@interface DemoListFeedExpressViewController () <UITableViewDelegate, UITableViewDataSource, AdvanceNativeExpressDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property(strong,nonatomic) AdvanceNativeExpress *advanceFeed;
@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation DemoListFeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"模板渲染信息流";
    
    _tableView = [[UITableView alloc] init];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [_tableView registerClass:[ExamTableViewCell class] forCellReuseIdentifier:@"ExamTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self loadBtnAction:nil];
}

- (void)loadBtnAction:(id)sender {
    _arrayData = [NSMutableArray arrayWithArray:[CellBuilder dataFromJsonFile:@"cell01"]];
    if (self.advanceFeed) {
        self.advanceFeed = nil;
    }
    // adSize 高度设置0自适应
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:self.adspotId customExt:self.ext viewController:self adSize:CGSizeMake(self.view.bounds.size.width, 0)];
    _advanceFeed.delegate = self;
    [_advanceFeed loadAd];
}

// MARK: ======================= AdvanceNativeExpressDelegate =======================

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

/// 信息流广告数据拉取成功
- (void)didFinishLoadingNativeExpressAds:(NSArray<AdvanceNativeExpressAd *> *)nativeAds spotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
}

/// 信息流广告渲染成功
/// 注意和广告数据拉取成功的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)nativeExpressAdViewRenderSuccess:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告渲染成功 %s %@", __func__, nativeAd);
    [_arrayData insertObject:nativeAd atIndex:1];
    [self.tableView reloadData];
}

/// 信息流广告渲染失败
/// 注意和广告加载失败的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
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

// MARK: ======================= UITableViewDelegate, UITableViewDataSource =======================

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_arrayData[indexPath.row] isKindOfClass:[BYExamCellModelElement class]]) {
        
        return ((BYExamCellModelElement *)_arrayData[indexPath.row]).cellh;
        
    } else {
        
        AdvanceNativeExpressAd *nativeAd = _arrayData[indexPath.row];
        UIView *view = [nativeAd expressView];
        CGFloat height = view.frame.size.height;
        if ([nativeAd.identifier isEqualToString:SDK_ID_TANX]) {
            return height + 10;
        } else {
            return height;
        }
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
        
        AdvanceNativeExpressAd *nativeAd = _arrayData[indexPath.row];
        UIView *view = [nativeAd expressView];
        view.tag = 1000;
        [cell.contentView addSubview:view];
        cell.accessibilityIdentifier = @"nativeTemp_ad";
        
        // 展示广告的cell高度 -tableView:heightForRowAtIndexPath:
        if ([nativeAd.identifier isEqualToString:SDK_ID_TANX]) { // tanx 的广告不带padding 需要自己调节
            [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(cell.contentView);
                make.left.equalTo(@(10));
                make.right.equalTo(@(-10));
                make.bottom.equalTo(@(10));
            }];
        }
        return cell;
    }
}
- (void)dealloc {
    NSLog(@"%s", __func__);
    self.advanceFeed = nil;
}

@end


