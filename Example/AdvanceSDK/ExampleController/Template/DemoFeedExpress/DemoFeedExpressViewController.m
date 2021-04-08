//
//  DemoFeedExpressViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoFeedExpressViewController.h"
#import "DemoListFeedExpressViewController.h"

@interface DemoFeedExpressViewController ()

@end

@implementation DemoFeedExpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"图片信息流", @"adspotId": @"100255-10002698"},
        @{@"addesc": @"图片信息流", @"adspotId": @"100255-100026981"},
        @{@"addesc": @"图片信息流", @"adspotId": @"100996-10003898"},
        @{@"addesc": @"图片信息流", @"adspotId": @"101361-10004249"},
        @{@"addesc": @"Mock 渠道错误", @"adspotId": @"100255-10000001"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10003321"},
        @{@"addesc": @"GDT2.0信息流", @"adspotId": @"100255-10002600"},
    ];
    self.btn1Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    DemoListFeedExpressViewController *vc = [[DemoListFeedExpressViewController alloc] init];
    vc.count = 1;
    vc.mediaId = self.mediaId;
    vc.adspotId = self.adspotId;
    vc.ext = self.ext;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
