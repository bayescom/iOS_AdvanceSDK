//
//  AdvBiddingInterstitialScapegoat.m
//  AdvanceSDK
//
//  Created by MS on 2023/3/29.
//

#import "AdvBiddingInterstitialScapegoat.h"
#import "AdvBiddingInterstitialCustomAdapter.h"
#import "AdvLog.h"
@interface AdvBiddingInterstitialScapegoat ()<ABUCustomSplashAdapter>
@property (nonatomic, assign) NSInteger price;
@end

@implementation AdvBiddingInterstitialScapegoat

- (void)advanceBiddingEndWithPrice:(NSInteger)price {
    self.price = price;
}

/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
    ADV_LEVEL_INFO_LOG(@"倍业聚合 出价: %ld",self.price);
    [self.a.bridge interstitialAd:self.a didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}


/// 广告曝光
- (void)advanceExposured {
    ADV_LEVEL_INFO_LOG(@"广告曝光回调 %s", __func__);
    [self.a.bridge interstitialAdDidVisible:self.a];
}

/// 广告点击
- (void)advanceClicked {
    ADV_LEVEL_INFO_LOG(@"广告点击 %s", __func__);
    [self.a.bridge interstitialAdDidClick:self.a];
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description {
    ADV_LEVEL_INFO_LOG(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

    [self.a.bridge interstitialAd:self.a didLoadFailWithError:error ext:@{}];
}



/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {

}


/// 广告关闭了
- (void)advanceDidClose {
    ADV_LEVEL_INFO_LOG(@"广告关闭了 %s", __func__);
    [self.a.bridge interstitialAdDidClose:self.a];
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

@end
