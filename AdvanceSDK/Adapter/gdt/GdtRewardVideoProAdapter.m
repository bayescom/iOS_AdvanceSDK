//
//  GdtRewardVideoProAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/27.
//

#import "GdtRewardVideoProAdapter.h"
#if __has_include(<GDTNativeExpressRewardVideoAd.h>)
#import <GDTNativeExpressRewardVideoAd.h>
#else
#import "GDTNativeExpressRewardVideoAd.h"
#endif
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"

@interface GdtRewardVideoProAdapter ()<GDTNativeExpressRewardedVideoAdDelegate>
@property (nonatomic, strong) GDTNativeExpressRewardVideoAd *gdt_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation GdtRewardVideoProAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceRewardVideo *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTNativeExpressRewardVideoAd alloc] initWithPlacementId:_supplier.adspotid];
    }
    return self;
}

- (void)loadAd {
    
    _gdt_ad.delegate = self;
    ADVLog(@"加载观点通 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"广点通 成功");
        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
            [self.delegate advanceUnifiedViewDidLoad];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"广点通 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"广点通 正在加载中");
    } else {
        ADVLog(@"广点通 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        _gdt_ad.delegate = self;
        _gdt_ad.videoMuted = NO; // 设置模板激励视频是否静音
        [_gdt_ad loadAd];
    }
}

- (void)showAd {
    [_gdt_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)deallocAdapter {
    _gdt_ad = nil;
}


- (void)dealloc {
    ADVLog(@"%s", __func__);
}

/**
 广告数据加载成功回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdDidLoad:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    NSLog(@"广点通激励视频拉取成功 %@",self.gdt_ad);
    if (_supplier.isParallel == YES) {
        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

/**
 视频数据下载成功回调，已经下载过的视频会直接回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdVideoDidLoad:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
}

/**
 视频播放页即将展示回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdWillVisible:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    
}

/**
 视频广告曝光回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdDidExposed:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/**
 视频播放页关闭回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdDidClose:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/**
 视频广告信息点击回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdDidClicked:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/**
 视频广告各种错误信息回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)gdt_nativeExpressRewardVideoAd:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
}

/**
 视频广告播放达到激励条件回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdDidRewardEffective:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective];
    }
}

/**
 视频广告视频播放完成

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_nativeExpressRewardVideoAdDidPlayFinish:(GDTNativeExpressRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }
}


@end
