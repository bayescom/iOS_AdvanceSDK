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
//        @{@"addesc": @"图片信息流", @"adspotId": @"100255-10002698"},
//        @{@"addesc": @"图片信息流", @"adspotId": @"100255-10006500"},
//        @{@"addesc": @"图片信息流", @"adspotId": @"100255-10006582"},
        
        //@{@"addesc": @"信息流-GroMore", @"adspotId": @"102768-10008589"},
        @{@"addesc": @"信息流-Bidding", @"adspotId": @"102768-10008534"},
        @{@"addesc": @"信息流-倍业", @"adspotId": @"102768-10007789"},
        @{@"addesc": @"信息流-穿山甲", @"adspotId": @"102768-10007799"},
        @{@"addesc": @"信息流-优量汇", @"adspotId": @"102768-10007808"},
        @{@"addesc": @"信息流-快手", @"adspotId": @"102768-10007817"},
        @{@"addesc": @"信息流-百度", @"adspotId": @"102768-10007834"},
        @{@"addesc": @"信息流-Tanx", @"adspotId": @"102768-10009464"}
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
