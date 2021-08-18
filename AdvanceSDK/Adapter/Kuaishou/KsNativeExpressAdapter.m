//
//  KsNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "KsNativeExpressAdapter.h"
#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
//#import "KSAdSDK.h"
#endif


#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressView.h"
@interface KsNativeExpressAdapter ()<KSFeedAdsManagerDelegate, KSFeedAdDelegate>
@property (nonatomic, strong) KSFeedAdsManager *ks_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSArray<AdvanceNativeExpressView *> * views;

@end

@implementation KsNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot; {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        
        _ks_ad = [[KSFeedAdsManager alloc] initWithPosId:_supplier.adspotid size:_adspot.adSize];

    }
    return self;
}

- (void)loadAd {
    int adCount = 1;

    ADV_LEVEL_INFO_LOG(@"加载快手");
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADV_LEVEL_INFO_LOG(@"快手 成功");
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADV_LEVEL_INFO_LOG(@"快手 失败");
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADV_LEVEL_INFO_LOG(@"快手 正在加载中");
    } else {
        ADV_LEVEL_INFO_LOG(@"快手 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        _ks_ad.delegate = self;
        [_ks_ad loadAdDataWithCount:adCount];
    }

    
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

- (void)feedAdsManagerSuccessToLoad:(KSFeedAdsManager *)adsManager nativeAds:(NSArray<KSFeedAd *> *_Nullable)feedAdDataArray {
//    self.title = @"数据加载成功";
    if (feedAdDataArray == nil || feedAdDataArray.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        if (_supplier.isParallel == YES) { // 并行不释放 只上报
            _supplier.state = AdvanceSdkSupplierStateFailed;
            return;
        }

//        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//            [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
//        }
    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        NSMutableArray *temp = [NSMutableArray array];
        for (KSFeedAd *ad in feedAdDataArray) {
            ad.delegate = self;
            [ad setVideoSoundEnable:NO];
            
            AdvanceNativeExpressView *TT = [[AdvanceNativeExpressView alloc] initWithViewController:_adspot.viewController];
            TT.expressView = ad.feedView;
            TT.identifier = _supplier.identifier;
            [temp addObject:TT];

        }
        self.views = temp;
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }

        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
        }
    }

//    [self refreshWithData:adsManager];
}

- (void)feedAdsManager:(KSFeedAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    NSLog(@"---> %@", error);
}

- (void)feedAdViewWillShow:(KSFeedAd *)feedAd {
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)feedAd.feedView];
    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
            [_delegate advanceNativeExpressOnAdShow:expressView];
        }
    }


}

- (void)feedAdDidClick:(KSFeedAd *)feedAd {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)feedAd.feedView];

    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
            [_delegate advanceNativeExpressOnAdClicked:expressView];
        }
    }
}

- (void)feedAdDislike:(KSFeedAd *)feedAd {
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)feedAd.feedView];
    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
            [_delegate advanceNativeExpressOnAdClosed:expressView];
        }
    }
}

- (void)feedAdDidShowOtherController:(KSFeedAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    
}

- (void)feedAdDidCloseOtherController:(KSFeedAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    
}

- (AdvanceNativeExpressView *)returnExpressViewWithAdView:(UIView *)adView {
    for (NSInteger i = 0; i < self.views.count; i++) {
        AdvanceNativeExpressView *temp = self.views[i];
        if (temp.expressView == adView) {
            return temp;
        }
    }
    return nil;
}



@end
