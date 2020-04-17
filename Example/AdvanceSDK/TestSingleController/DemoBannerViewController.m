//
//  DemoBannerViewController.m
//  Example
//
//  Created by 程立卿 on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoBannerViewController.h"
#import "ViewBuilder.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface DemoBannerViewController () <AdvanceBannerDelegate>
@property (nonatomic, strong) AdvanceBanner* advanceBanner;
@property (nonatomic, strong) UIView *contentV;

//@property (nonatomic, strong) UILabel *lbl01;
//@property (nonatomic, strong) UISwitch *switch01;
//@property (nonatomic, strong) UILabel *lbl02;
//@property (nonatomic, strong) UISwitch *switch02;
//@property (nonatomic, strong) UITextField *updateTimeTxtf;
//@property (nonatomic, strong) UIButton *updateTimeBtn;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"Banner", @"adspotId": @"10033-200031"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)reloadTimeTxtFChange:(UITextField *)textField {
    
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    if (!_contentV) {
        _contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/6.4)];
    }
    [self.adShowView addSubview:self.contentV];
    self.adShowView.hidden = NO;
    
    self.advanceBanner = [[AdvanceBanner alloc] initWithMediaId:self.mediaId adspotId:self.adspotId adContainer:self.contentV viewController:self];
    self.advanceBanner.delegate = self;
    [self.advanceBanner setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotid:@"10000558"
                                                mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkTag:SDK_TAG_MERCURY];
    [self.advanceBanner loadAd];
}

- (void)loadAdBtn2Action {
    
}

// MARK: ======================= advanceBannerDelegate =======================
- (void)advanceBannerOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

- (void)advanceBannerOnAdFailed {
    [DemoUtils showToast:@"广告失败"];

}

- (void)advanceBannerOnAdShow {
    [DemoUtils showToast:@"广告展示"];

}

- (void)advanceBannerOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];

}

@end
