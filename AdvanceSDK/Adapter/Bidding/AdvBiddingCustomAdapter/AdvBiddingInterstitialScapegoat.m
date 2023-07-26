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

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    //
}

/// 广告策略加载失败
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    ADV_LEVEL_INFO_LOG(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

    [self.a.bridge interstitialAd:self.a didLoadFailWithError:error ext:@{}];
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    //NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
    self.price = price;
}

/// 广告数据拉取成功
- (void)didFinishLoadingInterstitialADWithSpotId:(NSString *)spotId {
    ADV_LEVEL_INFO_LOG(@"倍业聚合 出价: %ld",self.price);
    [self.a.bridge interstitialAd:self.a didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}


/// 广告曝光
- (void)interstitialDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    ADV_LEVEL_INFO_LOG(@"广告曝光回调 %s", __func__);
    [self.a.bridge interstitialAdDidVisible:self.a];
}

/// 广告点击
- (void)interstitialDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    ADV_LEVEL_INFO_LOG(@"广告点击 %s", __func__);
    [self.a.bridge interstitialAdDidClick:self.a];
}

/// 广告关闭了
- (void)interstitialDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    ADV_LEVEL_INFO_LOG(@"广告关闭了 %s", __func__);
    [self.a.bridge interstitialAdDidClose:self.a];
}


- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

@end
