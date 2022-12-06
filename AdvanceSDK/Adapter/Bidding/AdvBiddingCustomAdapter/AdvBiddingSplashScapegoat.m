//
//  AdvBiddingSplashScapegoat.m
//  AdvanceSDK
//
//  Created by MS on 2022/9/28.
//

#import "AdvBiddingSplashScapegoat.h"
#import "AdvBiddingSplashCustomAdapter.h"
#import "AdvLog.h"
@interface AdvBiddingSplashScapegoat ()<ABUCustomSplashAdapter>
@property (nonatomic, assign) NSInteger price;
@end

@implementation AdvBiddingSplashScapegoat

- (void)advanceBiddingEndWithPrice:(NSInteger)price {
//    NSLog(@"%s %ld", __func__, (long)price);
    self.price = price;
}


/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
//    NSLog(@"广告数据拉取成功 %s", __func__);
    ADV_LEVEL_INFO_LOG(@"倍业聚合 出价: %ld",self.price);
    [self.a.bridge splashAd:self.a didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}

/// 广告曝光成功
- (void)advanceExposured {
//    NSLog(@"广告曝光成功 %s", __func__);
//    [self.a.bridge splashAdWillVisible:self];
    [self.a.bridge splashAdWillVisible:self.a];
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
//    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    ADV_LEVEL_INFO_LOG(@"倍业聚合 加载失败: %@", description);
    [self.a.bridge splashAd:self.a didLoadFailWithError:error ext:description];
//    - (void)splashAd:(id<ABUCustomSplashAdapter>_Nonnull)adapter didLoadFailWithError:(NSError *_Nullable)error ext:(NSDictionary *)ext;

}

/// 广告点击
- (void)advanceClicked {
//    NSLog(@"广告点击 %s", __func__);
    [self.a.bridge splashAdDidClick:self.a];
}

/// 广告关闭
- (void)advanceDidClose {
//    NSLog(@"广告关闭了 %s", __func__);
    [self.a.bridge splashAdDidClose:self.a];
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
//    NSLog(@"广告倒计时结束 %s", __func__);
    [self.a.bridge splashAdDidCountDownToZero:self.a];
}

/// 点击了跳过
- (void)advanceSplashOnAdSkipClicked {
//    NSLog(@"点击了跳过 %s", __func__);
    [self.a.bridge splashAdDidClickSkip:self.a];
//    [self.a.bridge splashAdDidClose:self];
}

// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
//    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    
}
@end
