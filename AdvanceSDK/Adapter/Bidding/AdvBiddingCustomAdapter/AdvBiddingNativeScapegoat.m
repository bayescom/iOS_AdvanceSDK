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
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(NSArray<AdvanceNativeExpressView *> *)views {
//    NSLog(@"广告拉取成功 %s", __func__);
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:views.count];
    NSMutableArray *exts = [NSMutableArray arrayWithCapacity:views.count];
    for (NSInteger i = 0; i < views.count; i++) {
        AdvanceNativeExpressView *view = views[i];
//        NSLog(@"1111:  %@ %ld", view.identifier, view.price);
        [list addObject:view.expressView];
        [exts addObject:@{
            ABUMediaAdLoadingExtECPM : @(view.price),
        }];
    }
    
    [self.a.bridge nativeAd:self.a didLoadWithExpressViews:[list copy] exts:exts.copy];

}


/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(AdvanceNativeExpressView *)adView {
//    NSLog(@"广告曝光 %s", __func__);
    [self.a.bridge nativeAd:self.a didVisibleWithMediatedNativeAd:adView.expressView];
}

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(AdvanceNativeExpressView *)adView {
//    NSLog(@"广告点击 %s", __func__);
    [self.a.bridge nativeAd:self.a didClickWithMediatedNativeAd:adView.expressView];
    [self.a.bridge nativeAd:self.a willPresentFullScreenModalWithMediatedNativeAd:adView.expressView];

}

/// 广告渲染成功
/// 注意和广告数据拉取成功的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)advanceNativeExpressOnAdRenderSuccess:(AdvanceNativeExpressView *)adView {
//    NSLog(@"广告渲染成功 %s %@", __func__, adView);
    [self.a.bridge nativeAd:self.a renderSuccessWithExpressView:adView.expressView];

}

/// 广告渲染失败
/// 注意和广告加载失败的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)advanceNativeExpressOnAdRenderFail:(AdvanceNativeExpressView *)adView {
//    NSLog(@"广告渲染失败 %s %@", __func__, adView);
    [self.a.bridge nativeAd:self.a renderFailWithExpressView:adView.expressView andError:nil];
}

/// 广告加载失败
/// 该回调只会触发一次
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
//    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
    [self.a.bridge nativeAd:self.a didLoadFailWithError:error];
}

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
//    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);

}

/// 加载策略成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
//    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(AdvanceNativeExpressView *)adView {
    //需要从tableview中删除
//    NSLog(@"广告关闭 %s", __func__);
    [self.a.bridge nativeAd:self.a didCloseWithExpressView:adView.expressView closeReasons:@[]];
}

@end
