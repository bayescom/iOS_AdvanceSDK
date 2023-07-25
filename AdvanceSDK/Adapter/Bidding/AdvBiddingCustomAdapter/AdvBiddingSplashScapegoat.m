//
//  AdvBiddingSplashScapegoat.m
//  AdvanceSDK
//
//  Created by MS on 2022/9/28.
//

#import "AdvBiddingSplashScapegoat.h"
#import "AdvBiddingSplashCustomAdapter.h"
#import "AdvLog.h"
@interface AdvBiddingSplashScapegoat ()
@property (nonatomic, assign) NSInteger price;
@end

@implementation AdvBiddingSplashScapegoat

// 策略请求成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    
}

/// 广告策略加载失败
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
//    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    ADV_LEVEL_INFO_LOG(@"倍业聚合 加载失败: %@", description);
    [self.a.bridge splashAd:self.a didLoadFailWithError:error ext:description];

}

/// 竞价成功
- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
//    NSLog(@"%s %ld", __func__, (long)price);
    self.price = price;
}


/// 开屏广告数据拉取成功
- (void)didFinishLoadingSplashADWithSpotId:(NSString *)spotId {
    ADV_LEVEL_INFO_LOG(@"倍业聚合 出价: %ld",self.price);
    [self.a.bridge splashAd:self.a didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}

/// 广告曝光成功
- (void)splashDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.a.bridge splashAdWillVisible:self.a];
}

/// 广告点击
- (void)splashDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告点击 %s", __func__);
    [self.a.bridge splashAdDidClick:self.a];
}

/// 广告关闭
- (void)splashDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告关闭了 %s", __func__);
    [self.a.bridge splashAdDidClose:self.a];
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    
}
@end
