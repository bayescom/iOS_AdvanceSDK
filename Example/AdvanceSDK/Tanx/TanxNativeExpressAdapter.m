//
//  TanxNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/7/14.
//

#import "TanxNativeExpressAdapter.h"
#if __has_include(<TanxSDK/TanxSDK.h>)
#import <TanxSDK/TanxSDK.h>
#else
#import "TanxSDK.h"
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
#if !__has_feature(objc_arc)
    // Safe releases

    //iOS 4 and above. to avoid retain cycles
    #define ADVTXAdBlockWeakObject(obj, wobj)  __block __typeof__((__typeof__(obj))obj) wobj = obj
    #define ADVTXAdBlockStrongObject(obj, sobj) __typeof__((__typeof__(obj))obj) sobj = [[obj retain] autorelease]

#else // !__has_feature(objc_arc)
    // Safe releases

    //iOS 4 and above. to avoid retain cycles
    #define ADVTXAdBlockWeakObject(obj, wobj)  __weak __typeof__((__typeof__(obj))obj) wobj = obj
    #define ADVTXAdBlockStrongObject(obj, sobj) __typeof__((__typeof__(obj))obj) sobj = obj

#endif // !__has_feature(objc_arc)

@interface TanxNativeExpressAdapter () <TXAdFeedManagerDelegate>
@property (nonatomic, strong) TXAdFeedManager *feedMgr;
@property (nonatomic, strong) TXAdFeedTemplateConfig *config;

@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;
@end

@implementation TanxNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        self.feedMgr = [[TXAdFeedManager alloc] initWithDelegate:self andScrollView:nil];
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Tanx supplier: %@", _supplier);

    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [self loadTanxNativeExpress];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Tanx加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Tanx 成功");
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"Tanx 失败");
//    [self.adspot loadnexsuuupl]
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    
}

- (void)dealloc {

}

- (void)loadTanxNativeExpress {
    //第一步获取信息流数据
    
    ADVTXAdBlockWeakObject(self,weakSelf);
    [weakSelf.feedMgr getFeedAdWithBlock:^(NSArray<TXAdFeedModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        ADVTXAdBlockStrongObject(self, strongSelf);
        if (!error) {
            TXAdFeedModel *model = viewModelArray.firstObject;
            strongSelf->_supplier.supplierPrice = (model.eCPM == nil) ? 0 : model.eCPM.integerValue;
            
            
            [strongSelf->_adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:strongSelf->_supplier error:nil];
            [strongSelf->_adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:strongSelf->_supplier error:nil];

            //第二步获取模板信息
            strongSelf.config.verticalPadding = strongSelf.config.horizontalPadding = 10.f;
            NSMutableArray *creativeIds = [[NSMutableArray alloc] initWithCapacity:0];
            
            [creativeIds addObject:model.creativeId];

            NSArray <TXAdFeedModule *>*views = [strongSelf.feedMgr renderFeedTemplateWithModel:viewModelArray joinBidding:NO andCreativeIds:creativeIds andTemplateConfig:strongSelf.config];
            
            
            strongSelf.nativeAds = [NSMutableArray array];

            for (TXAdFeedModule *module in views) {
                AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] initWithViewController:strongSelf->_adspot.viewController];
                TT.expressView = module.view;
                TT.identifier = strongSelf->_supplier.identifier;
                TT.price = (model.eCPM == nil) ? strongSelf->_supplier.supplierPrice : model.eCPM.integerValue;

                [strongSelf.nativeAds addObject:TT];
            }
            
            if (strongSelf->_supplier.isParallel == YES) {
    //            NSLog(@"修改状态: %@", _supplier);
                strongSelf->_supplier.state = AdvanceSdkSupplierStateSuccess;
                return;
            }

            
            if ([strongSelf->_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
                [strongSelf->_delegate didFinishLoadingNativeExpressAds:strongSelf.nativeAds spotId:strongSelf.adspot.adspotid];
            }

        } else {
            [strongSelf->_adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:strongSelf->_supplier error:nil];
            strongSelf->_supplier.state = AdvanceSdkSupplierStateFailed;
            if (strongSelf->_supplier.isParallel == YES) {
                return;
            }
        }

    } withPid:_supplier.adspotid andPosArray:@[@0] renderMode:TXAdFeedRenderModeTemplate];
}


/// 点击了广告
- (void)onClickingFeed:(TXAdFeedModel *)feedModel {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = self.nativeAds.firstObject;
    
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 广告渲染成功
- (void)onRenderSuc:(TXAdFeedModel *)feedModel {
    
    AdvanceNativeExpressAd *nativeAd = self.nativeAds.firstObject;
    
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }

}

/// 广告展示（曝光）
- (void)onExposingFeed:(TXAdFeedModel *)feedModel {
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = self.nativeAds.firstObject;

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }

}

/// 点击了广告关闭按钮
- (void)onClickCloseFeed:(TXAdFeedModel *)feedModel {
    
    AdvanceNativeExpressAd *nativeAd = self.nativeAds.firstObject;
    
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 点击了“不喜欢”菜单中的选项
/// @param feedModel  feedModel模型
/// @param index  选项次序索引
- (void)didCloseFeed:(TXAdFeedModel*)feedModel atIndex:(NSInteger)index {
    
}

/// 广告加载失败
/// @param feedModel  feedModel模型
/// @param error 错误信息
- (void)onFailureFeed:(TXAdFeedModel *)feedModel andError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:nil];
    
    AdvanceNativeExpressAd *nativeAd = self.nativeAds.firstObject;
    
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }

}




- (void)jumpToWebH5:(NSString *)webUrl {
//    TXAdSplashWebViewontroller *splashVC = [TXAdSplashWebViewontroller new];
//    TXAdSplashModel *model = [[TXAdSplashModel alloc] initWithDictionary:@{@"click_through_url":webUrl} error:nil];
//    [splashVC setSplashModel:model];
//    [self.navigationController pushViewController:splashVC animated:YES];
}

- (AdvanceNativeExpressAd *)returnExpressViewWithAdView:(UIView *)adView {
    for (NSInteger i = 0; i < self.nativeAds.count; i++) {
        AdvanceNativeExpressAd *temp = self.nativeAds[i];
        if (temp.expressView == adView) {
            return temp;
        }
    }
    return nil;
}


@end
