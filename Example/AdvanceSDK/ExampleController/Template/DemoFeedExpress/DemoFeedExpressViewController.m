//
//  DemoFeedExpressViewController.m
//  Example
//
//  Created by 程立卿 on 2019/12/20.
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
        @{@"addesc": @"图片信息流", @"adspotId": @"10033-200046"},
    ];
    self.btn1Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    DemoListFeedExpressViewController *vc = [[DemoListFeedExpressViewController alloc] init];
    vc.count = 1;
    vc.mediaId = self.mediaId;
    vc.adspotId = self.adspotId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
