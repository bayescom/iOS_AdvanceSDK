//
//  TanxSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "TanxSplashAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceSplash.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface TanxSplashAdapter () <TXAdSplashManagerDelegate, AdvanceAdapter>
@property(nonatomic, strong)TXAdSplashManager *tanx_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) TXAdModel *adModel;
@property(nonatomic, strong) UIView *templateView;
@property (nonatomic, strong) UIImageView *imgV;

@end

@implementation TanxSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        TXAdSplashSlotModel *slotModel = [[TXAdSplashSlotModel alloc] init];
        slotModel.pid = _supplier.adspotid;
        slotModel.waitSyncTimeout = _supplier.timeout * 1.0 / 1000.0;
        _tanx_ad = [[TXAdSplashManager alloc] initWithSlotModel:slotModel];
        _tanx_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getSplashAdsWithAdsDataBlock:^(NSArray<TXAdModel *> *splashModels, NSError *error) {
        if (error) { // 获取广告失败
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:weakSelf.supplier error:error];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdFailed];
            
        } else { // 获取广告成功
            self.adModel = splashModels.firstObject;
            NSInteger ecpm = self.adModel.bid.bidPrice.integerValue;
            if (ecpm > 0) {
                [self.tanx_ad uploadBidding:self.adModel result:YES];
            }
            [weakSelf.adspot.manager setECPMIfNeeded:ecpm supplier:weakSelf.supplier];
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:weakSelf.supplier error:nil];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdSuccess];
        }
    }];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (void)showInWindow:(UIWindow *)window {
    // 设置logo
    CGRect adFrame = [UIScreen mainScreen].bounds;
    if (_adspot.logoImage && _adspot.showLogoRequire) {
        
        NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        adFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-real_h);
        
        self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, real_w, real_h)];
        self.imgV.userInteractionEnabled = YES;
        self.imgV.image = _adspot.logoImage;
        [window addSubview:self.imgV];
    }
    
    TXAdSplashTemplateConfig *config = [[TXAdSplashTemplateConfig alloc] init];
    self.templateView = [self.tanx_ad renderSplashTemplateWithAdModel:self.adModel config:config];
    self.templateView.frame = adFrame;
    [window addSubview:self.templateView];
}

#pragma mark: -TXAdSplashManagerDelegate
/// 开始展示
- (void)onSplashShow {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)] && self.tanx_ad) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 关闭
- (void)onSplashClose {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
    [_imgV removeFromSuperview];
    _imgV = nil;
    [_templateView removeFromSuperview];
    _templateView = nil;
}

/// 点击了跳转
- (void)onAdClick:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)dealloc {
    ADVLog(@"%s %@", __func__, self);
}

@end
