//
//  BdNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "BdNativeExpressAdapter.h"
#if __has_include(<BaiduMobAdSDK/BaiduMobAdNative.h>)
#import <BaiduMobAdSDK/BaiduMobAdNative.h>
#import <BaiduMobAdSDK/BaiduMobAdSmartFeedView.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdView.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeVideoView.h>
#import <BaiduMobAdSDK/BaiduMobAdActButton.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdSmartFeedView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeVideoView.h"
#import "BaiduMobAdSDK/BaiduMobAdActButton.h"
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
@class BaiduMobAdActButton;

@interface BdNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) NSMutableArray *adViewArray;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation BdNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdNative alloc] init];
        _bd_ad.adDelegate = self;
        _bd_ad.publisherId = _supplier.mediaid;
        _bd_ad.adUnitTag = _supplier.adspotid;
        _bd_ad.presentAdViewController = _adspot.viewController;
        self.adViewArray = [NSMutableArray array];
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_bd_ad requestNativeAds];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"百度加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"百度 成功");
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (self.bd_ad) {
        self.bd_ad.adDelegate = nil;
        self.bd_ad = nil;
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);

    [self deallocAdapter];
}

- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (nativeAds == nil || nativeAds.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        _supplier.state = AdvanceSdkSupplierStateFailed;
        if (_supplier.isParallel == YES) {
            return;
        }

    } else {
        _supplier.supplierPrice = [[nativeAds.firstObject getECPMLevel] integerValue];
        [_adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
        NSMutableArray *temp = [NSMutableArray array];
        
        for (int i = 0; i < nativeAds.count; i++) {
            
            CGFloat height = (UIScreen.mainScreen.bounds.size.width-30)*2/3+130;
            BaiduMobAdNativeAdObject *object = nativeAds[i];
            object.interationDelegate = self;
            BaiduMobAdNativeAdView *view = [self createNativeAdViewWithframe:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height) object:object];
            
            if (view) {
                [self.adViewArray addObject:view];
            }
            
            //展现前检查是否过期，通常广告过期时间为30分钟。如果过期，请放弃展示并重新请求
            if ([object isExpired]) {
                continue;
            }
            
            [view loadAndDisplayNativeAdWithObject:object completion:^(NSArray *errors) {
                if (!errors) {
                    NSLog(@"fdgf");
                }
            }];
            
            AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] initWithViewController:_adspot.viewController];
            TT.expressView = view;
            TT.identifier = _supplier.identifier;
            TT.price = ([[object getECPMLevel] integerValue] == 0) ?  _supplier.supplierPrice : [[object getECPMLevel] integerValue];

            [temp addObject:TT];
        }
        
        self.nativeAds = temp;
        if (_supplier.isParallel == YES) {
//            NSLog(@"修改状态: %@", _supplier);
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }
        
        if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
            [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
        }
    }

}

//广告返回失败
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000030 + reason userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }

    _bd_ad = nil;

}

// 负反馈点击选项回调
- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
//    NSLog(@"智能优选负反馈点击：%@", object);
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:adView];
    if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
        [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
    }

}


//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
//    NSLog(@"信息流被点击:%@ - %@", nativeAdView, object);
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
- (void)didDismissLandingPage:(UIView *)nativeAdView {

}

//广告曝光成功
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
//    NSLog(@"信息流广告曝光成功:%@ - %@", nativeAdView, object);
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
        
        [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }

    }
    
}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
//    NSLog(@"信息流广告曝光失败:%@ - %@，reason：%d", nativeAdView, object, reason);
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
        [self.nativeAds removeObject:nativeAd];
    }

}

// 联盟官网点击跳转
- (void)unionAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{
//    NSLog(@"信息流广告百香果点击回调");
}

- (void)tapGesture:(UIGestureRecognizer *)sender {
    UIView *view = sender.view ;

    if ([view isKindOfClass:[BaiduMobAdSmartFeedView class]]) {
        BaiduMobAdSmartFeedView *adView = (BaiduMobAdSmartFeedView *)view;
        [adView handleClick];
        return;
    }
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

#pragma mark - 创建广告视图

- (BaiduMobAdNativeAdView *)createNativeAdViewWithframe:(CGRect)frame object:(BaiduMobAdNativeAdObject *)object {
    
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat origin_x = 15;
    CGFloat main_width = screenWidth - (origin_x*2);
    CGFloat main_height = main_width*2/3;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 20, main_width-85, 20)];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    
    //描述
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(85, 50, main_width-85, 20)];
    textLabel.font = [UIFont fontWithName:textLabel.font.familyName size:12];
    if (!object.text || [object.text isEqualToString:@""]) {
        object.text = @"广告描述信息";
    }
    
    //Icon
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, origin_x, 60, 60)];
    iconImageView.layer.cornerRadius = 3;
    iconImageView.layer.masksToBounds = YES;
    
    //大图
    UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, 85, main_width, main_height)];
    mainImageView.layer.cornerRadius = 5;
    mainImageView.layer.masksToBounds = YES;
    
    //app名字
    UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin_x, CGRectGetMaxY(mainImageView.frame) + 20, 60, 14)];
    brandLabel.font = [UIFont fontWithName:brandLabel.font.familyName size:13];
    brandLabel.textColor = [UIColor grayColor];
    
    //广告logo
    UIImageView *baiduLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(brandLabel.frame), CGRectGetMinY(brandLabel.frame), 15, 14)];
    UIImageView *adLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(baiduLogoView.frame), CGRectGetMinY(baiduLogoView.frame), 26, 14)];
    
    
    BaiduMobAdActButton *actButton = [[BaiduMobAdActButton alloc] initWithFrame:CGRectMake(screenWidth - 80 - origin_x, CGRectGetMinY(brandLabel.frame) - 10, 80, 30)];
    [actButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    //多图 Demo  单图和多图按需展示
    NSMutableArray *imageViewArray = [NSMutableArray array];
    if ([object.morepics count] > 0) {
        //多图
        CGFloat margin = 5;//图片间隙
        CGFloat imageWidth = (screenWidth-2*origin_x-margin*(object.morepics.count-1))/object.morepics.count;
        CGFloat imageHeight = imageWidth*2/3;
        
        //适配logo位置
        actButton.frame = ({
            CGRect frame = actButton.frame;
            frame.origin.y = imageHeight + 10 + 85;
            frame;
        });
        
        baiduLogoView.frame = ({
            CGRect frame = baiduLogoView.frame;
            frame.origin.y = CGRectGetMinY(actButton.frame) + 10;
            frame;
        });
        
        adLogoView.frame = ({
            CGRect frame = adLogoView.frame;
            frame.origin.y = CGRectGetMinY(baiduLogoView.frame);
            frame;
        });
        
        brandLabel.frame = ({
            CGRect frame = brandLabel.frame;
            frame.origin.y = CGRectGetMinY(baiduLogoView.frame);
            frame;
        });
        
        
        for (int i = 0; i<object.morepics.count; i++) {
            UIImageView *mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin_x, 85, imageWidth, imageHeight)];
            [imageViewArray addObject:mainImageView];
            origin_x+=imageWidth+margin;
        }
    }
    
    BaiduMobAdNativeAdView *nativeAdView;
    nativeAdView.backgroundColor = [UIColor whiteColor];
    
    if (object.materialType == NORMAL) {
        
        //多图 Demo  单图和多图按需展示
        nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:frame
                                                           brandName:brandLabel
                                                               title:titleLabel
                                                                text:textLabel
                                                                icon:iconImageView
                                                           mainImage:mainImageView
                                                            morepics:imageViewArray];
        
    }
    // 自定义logo
    nativeAdView.baiduLogoImageView = baiduLogoView;
    [nativeAdView addSubview:baiduLogoView];
    nativeAdView.adLogoImageView = adLogoView;
    [nativeAdView addSubview:adLogoView];
    nativeAdView.actButton = actButton;
    [nativeAdView addSubview:actButton];
    
    return nativeAdView;
}


@end
