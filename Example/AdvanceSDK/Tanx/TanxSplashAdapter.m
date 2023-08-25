////
////  TanxSplashAdapter.m
////  AdvanceSDK
////
////  Created by MS on 2022/7/13.
////  Copyright © 2022 Cheng455153666. All rights reserved.
////
//
//#import "TanxSplashAdapter.h"
//#if __has_include(<TanxSDK/TanxSDK.h>)
//#import <TanxSDK/TanxSDK.h>
//#else
//#import "TanxSDK.h"
//#endif
//
//#import "AdvanceSplash.h"
//#import "UIApplication+Adv.h"
//#import "AdvLog.h"
//#import <objc/runtime.h>
//#import <objc/message.h>
//
//#if !__has_feature(objc_arc)
//// Safe releases
//
////iOS 4 and above. to avoid retain cycles
//#define ADVTXAdBlockWeakObject(obj, wobj)  __block __typeof__((__typeof__(obj))obj) wobj = obj
//#define ADVTXAdBlockStrongObject(obj, sobj) __typeof__((__typeof__(obj))obj) sobj = [[obj retain] autorelease]
//
//#else // !__has_feature(objc_arc)
//// Safe releases
//
////iOS 4 and above. to avoid retain cycles
//#define ADVTXAdBlockWeakObject(obj, wobj)  __weak __typeof__((__typeof__(obj))obj) wobj = obj
//#define ADVTXAdBlockStrongObject(obj, sobj) __typeof__((__typeof__(obj))obj) sobj = obj
//
//#endif // !__has_feature(objc_arc)
//
//@interface TanxSplashAdapter ()<TXAdSplashManagerDelegate>
//{
//
//    NSInteger _timeout;
//    NSInteger _timeout_stamp;
//
//}
//@property(nonatomic, strong) TXAdSplashManager *splashManager;
//@property(nonatomic, strong) UIView *templateView;
//@property(nonatomic, strong) UIWindow *window;
//@property(nonatomic, weak) AdvanceSplash *adspot;
//@property(nonatomic, strong) AdvSupplier *supplier;
//@property(nonatomic, strong)NSArray <TXAdSplashModel *> *splashModels;
//@property(nonatomic, assign) BOOL isClick;
//@property(nonatomic, strong) UIImageView *imgV;
//
//@end
//
//
//@implementation TanxSplashAdapter
//- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
//    if (self = [super initWithSupplier:supplier adspot:adspot]) {
//        _adspot = adspot;
//        _supplier = supplier;
//        TXAdSplashManager *splashManager = [[TXAdSplashManager alloc] init];
//        splashManager.delegate = self;
//        self.splashManager = splashManager;
//
//    }
//    return self;
//}
//
//- (void)supplierStateLoad {
//    ADV_LEVEL_INFO_LOG(@"加载Tanx supplier: %@", _supplier);
//    ADVTXAdBlockWeakObject(self, blockObj);
//    [self.splashManager getSplashAdsWithBlock:^(NSArray<TXAdSplashModel *> * _Nullable splashModels, NSError * _Nullable error) {
//        if (error) {
//            [self tanxSplashAdFailToPresentWithError:error];
//        } else {
//            if (splashModels.count == 0) {
//                NSError *temp = [NSError errorWithDomain:@"Tanx广告数组个数为0" code:10001 userInfo:nil];
//                [self tanxSplashAdFailToPresentWithError:temp];
//            } else {
//                [blockObj tanxSplashAdDidLoadWithModels:splashModels];
//            }
//        }
//
//
//    } withPid:_supplier.adspotid];
//}
//
//- (void)supplierStateInPull {
//    ADV_LEVEL_INFO_LOG(@"Tanx加载中...");
//}
//
//- (void)supplierStateSuccess {
//    ADV_LEVEL_INFO_LOG(@"Tanx 成功");
//    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
//        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
//    }
//    [self showAd];
//
//}
//
//- (void)supplierStateFailed {
//    ADV_LEVEL_INFO_LOG(@"Tanx 失败");
//    [self.adspot loadNextSupplierIfHas];
//    [self deallocAdapter];
//}
//
//
//- (void)loadAd {
//    [super loadAd];
//}
//
//
//- (void)deallocAdapter {
//    //    __weak typeof(self) _self = self;
//    //    dispatch_async(dispatch_get_main_queue(), ^{
//    //        __strong typeof(_self) self = _self;
//    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
//        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
//    }
//    [self.splashManager removeLocalAssets];
//    [self.templateView removeFromSuperview];
//    [self.imgV removeFromSuperview];
//    self.templateView = nil;
//    self.imgV = nil;
//    self.splashManager.delegate = nil;
//    self.splashManager = nil;
//    //    });
//}
//
//- (void)gmShowAd {
//    [self showAdAction];
//}
//
//- (void)showAd {
//    NSNumber *isGMBidding = ((NSNumber * (*)(id, SEL))objc_msgSend)((id)self.adspot, @selector(isGMBidding));
//
//    if (isGMBidding.integerValue == 1) {
//        return;
//    }
//    [self showAdAction];
//}
//
//- (void)showAdAction {
//    // 设置logo
//    __weak typeof(self) _self = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        __strong typeof(_self) self = _self;
//        if (_adspot.logoImage  && _adspot.showLogoRequire) {
//            NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
//
//            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
//            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
//            self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - real_h, real_w, real_h)];
//            self.imgV.userInteractionEnabled = YES;
//            self.imgV.image = _adspot.logoImage;
//        }
//        if (self.splashManager) {
//
//            //渲染模板
//            self.window = [UIApplication sharedApplication].adv_getCurrentWindow;
//
//            TXAdSplashModel *splashModel = self.splashModels.firstObject;
//            TXAdSplashTemplateConfig *config = [[TXAdSplashTemplateConfig alloc] init];
//
//            self.templateView = [self.splashManager renderSplashTemplateWithModel:splashModel config:config];
//            self.templateView.frame = CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height - self.imgV.frame.size.height);
//            //            ADV_LEVEL_INFO_LOG(@"Tanx失败  %@---> %@  %d", self, self.templateView, splashModel.isValid);
//            if (self.templateView == nil || splashModel.isValid == NO) {
//                NSError *temp = [NSError errorWithDomain:@"广告物料加载失败" code:10002 userInfo:nil];
//                [self tanxSplashAdFailToPresentWithError:temp];
//            } else {
//                [self.window addSubview:self.templateView];
//                if (self.imgV) {
//                    [self.window addSubview:self.imgV];
//                }
//                [self.window bringSubviewToFront:self.templateView];
//            }
//            [self biddingWithSplashModel:splashModel isWin:YES];
//        }
//    });
//
//}
//
//// 加载成功
//- (void)tanxSplashAdDidLoadWithModels:(NSArray <TXAdSplashModel *>*)splashModels {
//    self.splashModels = splashModels;
//    TXAdSplashModel *model = self.splashModels.firstObject;
//
//    _supplier.supplierPrice = (model.eCPM == nil) ? 0 : model.eCPM.integerValue ;
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
//
//    if (_supplier.isParallel == YES) {
//        //        ADV_LEVEL_INFO_LOG(@"修改状态: %@", _supplier);
//        _supplier.state = AdvanceSdkSupplierStateSuccess;
//        return;
//    }
//    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
//        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
//    }
//
//    [self showAd];
//
//}
//
//- (void)onSplashClickWithWebUrl:(NSString *)webUrl {
//    ADV_LEVEL_INFO_LOG(@"%s  %@",__func__, webUrl);
//
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
//    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
//        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
//    }
//    _isClick = YES;
//
//    [self.splashManager removeLocalAssets];
//    [self.templateView removeFromSuperview];
//    [self.imgV removeFromSuperview];
//    self.templateView = nil;
//    self.imgV = nil;
//    self.splashManager = nil;
//    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
//        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
//    }
//
//}
//
//
///// 开屏开始展示
//- (void)onSplashShow {
//    ADV_LEVEL_INFO_LOG(@"%s",__func__);
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
//    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)]) {
//        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
//    }
//
//    _timeout = 5;
//    // 记录过期的时间
//    _timeout_stamp = ([[NSDate date] timeIntervalSince1970] + _timeout)*1000;
//
//
//}
//
///// 开屏关闭
//- (void)onSplashClose {
//    ADV_LEVEL_INFO_LOG(@"%s",__func__);
//
//    if ([[NSDate date] timeIntervalSince1970]*1000 < _timeout_stamp && _isClick == NO) {// 关闭时的时间小于过期时间 且 没有被点击广告区域  则点击了跳过
//        //        ADV_LEVEL_INFO_LOG(@"%f, %ld",[[NSDate date] timeIntervalSince1970]*1000,  _timeout_stamp);
//        if (self.delegate && [self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
//            [self.delegate advanceSplashOnAdSkipClicked];
//        }
//    } else if ([[NSDate date] timeIntervalSince1970]*1000 < _timeout_stamp && _isClick == YES) {// 关闭时的时间小于过期时间 且 点击了广告区域  则不发生什么
//
//    } else {// 关闭时的时间大于过期时间 则为倒计时 自动关闭
//        if (self.delegate && [self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
//            [self.delegate advanceSplashOnAdCountdownToZero];
//        }
//    }
//
//    [self.splashManager removeLocalAssets];
//    [self.templateView removeFromSuperview];
//    [self.imgV removeFromSuperview];
//    self.templateView = nil;
//    self.imgV = nil;
//    self.splashManager = nil;
//    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
//        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
//    }
//
//    //    [self deallocAdapter];
//}
//
//
//// 加载失败
//- (void)tanxSplashAdFailToPresentWithError:(NSError *)error {
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
//    _supplier.state = AdvanceSdkSupplierStateFailed;
//    if (_supplier.isParallel == YES) {
//        return;
//    }
//
//}
//
//// 上报价格
//- (void)biddingWithSplashModel:(TXAdSplashModel *)splashModel isWin:(BOOL)isWin
//{
//    [self.splashManager uploadBidding:splashModel isWin:isWin];
//}
//
//- (UIImageView *)imgV {
//    if (!_imgV) {
//        _imgV = [UIImageView new];
//    }
//    return _imgV;
//}
//
//- (void)dealloc
//{
//    ADV_LEVEL_INFO_LOG(@"%s", __func__);
//}
//@end
