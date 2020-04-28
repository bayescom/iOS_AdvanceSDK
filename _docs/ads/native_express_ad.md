## 原生模板

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