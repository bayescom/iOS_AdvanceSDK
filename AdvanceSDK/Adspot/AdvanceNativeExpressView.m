//
//  AdvanceNativeExpressView.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/4.
//

#import "AdvanceNativeExpressView.h"

@interface AdvanceNativeExpressView ()
@property (nonatomic, strong) UIViewController *controller;
@end

@implementation AdvanceNativeExpressView
- (instancetype)initWithViewController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        _controller = controller;
    }
    return self;
}
- (void)render {
    if (self.controller != nil && self.expressView != nil) {
        return;
    }
    if ([self.expressView isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")] ||
        [self.expressView isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")]) {
        [self.expressView performSelector:@selector(setRootViewController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
        [self.expressView performSelector:@selector(setController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {// 广点通旧版信息流
        [self.expressView performSelector:@selector(setController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"GDTNativeExpressProAdView")]) {// 广点通新版信息流
        [self.expressView performSelector:@selector(setController:) withObject:_controller];
        [self.expressView performSelector:@selector(render)];
    } else if ([self.expressView isKindOfClass:NSClassFromString(@"BaiduMobAdSmartFeedView")]) {// 百度
        [self.expressView performSelector:@selector(render)];
    } else { // 快手
        
    }

}

- (void)setExpressView:(UIView *)expressView {
    _expressView = expressView;
}

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(UIView *)adView {
    NSLog(@"广告曝光 %s", __func__);
}

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(UIView *)adView {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告渲染成功
/// 注意和广告数据拉取成功的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)advanceNativeExpressOnAdRenderSuccess:(UIView *)adView {
    NSLog(@"广告渲染成功 %s %@", __func__, adView);

}

/// 广告渲染失败
/// 注意和广告加载失败的区别  广告数据拉取成功, 但是渲染可能会失败
/// 广告加载失败 是广点通 穿山甲 mercury 在拉取广告的时候就全部失败了
/// 该回调的含义是: 比如: 广点通拉取广告成功了并返回了一组view  但是其中某个view的渲染失败了
/// 该回调会触发多次
- (void)advanceNativeExpressOnAdRenderFail:(UIView *)adView {
    NSLog(@"广告渲染失败 %s %@", __func__, adView);
}

/// 广告加载失败
/// 该回调只会触发一次
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

}

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);

}

/// 加载策略成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(UIView *)adView {
    //需要从tableview中删除
    NSLog(@"广告关闭 %s", __func__);
}

@end
