
#import "DemoRenderFeedViewController.h"
#import "DemoFeedAdDisplayController.h"

@interface DemoRenderFeedViewController ()


@end

@implementation DemoRenderFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"自渲染-穿山甲随机", @"adspotId": @"102768-10008353"},
        @{@"addesc": @"自渲染-优量汇图片", @"adspotId": @"102768-10008354"},
        @{@"addesc": @"自渲染-优量汇视频", @"adspotId": @"102768-10008355"},
        @{@"addesc": @"自渲染-策略", @"adspotId": @"102768-10008339"},
    ];
    self.btn1Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    DemoFeedAdDisplayController *vc = [[DemoFeedAdDisplayController alloc] init];
    vc.adspotId = self.adspotId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
