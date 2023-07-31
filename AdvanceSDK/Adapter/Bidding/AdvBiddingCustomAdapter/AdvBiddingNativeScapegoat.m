//
//  AdvBiddingNativeScapegoat.m
//  AdvanceSDK
//
//  Created by MS on 2022/10/25.
//

#import "AdvBiddingNativeScapegoat.h"
#import "AdvBiddingNativeExpressCustomAdapter.h"
@implementation AdvBiddingNativeScapegoat

// MARK: ======================= AdvanceNativeExpressDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略加载失败
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    [self.a.bridge nativeAd:self.a didLoadFailWithError:error];
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 信息流广告数据拉取成功
- (void)didFinishLoadingNativeExpressAds:(NSArray<AdvanceNativeExpressAd *> *)nativeAds spotId:(NSString *)spotId {
    
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:nativeAds.count];
    NSMutableArray *exts = [NSMutableArray arrayWithCapacity:nativeAds.count];
    for (NSInteger i = 0; i < nativeAds.count; i++) {
        AdvanceNativeExpressAd *nativeAd = nativeAds[i];
        //        NSLog(@"1111:  %@ %ld", view.identifier, view.price);
        [list addObject:nativeAd.expressView];
        [exts addObject:@{
            ABUMediaAdLoadingExtECPM : @(nativeAd.price),
        }];
    }
    
    [self.a.bridge nativeAd:self.a didLoadWithExpressViews:[list copy] exts:exts.copy];
}

/// 信息流广告渲染成功
/// 注意和广告数据拉取成功的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)nativeExpressAdViewRenderSuccess:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    // NSLog(@"广告渲染成功 %s %@", __func__, adView);
    [self.a.bridge nativeAd:self.a renderSuccessWithExpressView:nativeAd.expressView];
}

/// 信息流广告渲染失败
/// 注意和广告加载失败的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)nativeExpressAdViewRenderFail:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    // NSLog(@"广告渲染失败 %s %@", __func__, adView);
        [self.a.bridge nativeAd:self.a renderFailWithExpressView:nativeAd.expressView andError:nil];
}

/// 信息流广告曝光
-(void)didShowNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告曝光 %s", __func__);
    [self.a.bridge nativeAd:self.a didVisibleWithMediatedNativeAd:nativeAd.expressView];
}

/// 信息流广告点击
-(void)didClickNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告点击 %s", __func__);
    [self.a.bridge nativeAd:self.a didClickWithMediatedNativeAd:nativeAd.expressView];
    [self.a.bridge nativeAd:self.a willPresentFullScreenModalWithMediatedNativeAd:nativeAd.expressView];

}

/// 信息流广告被关闭
-(void)didCloseNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    //需要从tableview中删除
//    NSLog(@"广告关闭 %s", __func__);
    [self.a.bridge nativeAd:self.a didCloseWithExpressView:nativeAd.expressView closeReasons:@[]];
}

@end
