//
//  AdvBiddingRewardVideoCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/8/10.
//

#import "AdvBiddingRewardVideoCustomAdapter.h"
#import <AdvanceSDK/AdvanceRewardVideo.h>
#import "AdvBiddingRewardVideoScapegoat.h"
#import "AdvBiddingCongfig.h"
#import "AdvSupplierModel.h"
#import "UIApplication+Adv.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

@interface AdvBiddingRewardVideoCustomAdapter ()<AdvanceRewardVideoDelegate>
@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
@property (nonatomic, strong) AdvBiddingRewardVideoScapegoat *scapegoat;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) NSInteger price;

@end

@implementation AdvBiddingRewardVideoCustomAdapter

- (AdvBiddingRewardVideoScapegoat *)scapegoat {
    if (!_scapegoat) {
        _scapegoat = [[AdvBiddingRewardVideoScapegoat alloc]init];
        _scapegoat.a = self;
    }
    return _scapegoat;
}

- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

- (void)loadRewardedVideoAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
//    NSLog(@"----------->自定义激励视频adapter开始加载啦啦<------------");
    AdvSupplierModel *model = [[AdvBiddingCongfig defaultManager] returnSupplierByAdspotId:slotID];

//    NSLog(@"--> %@  ", [UIApplication sharedApplication].adv_getCurrentWindow.rootViewController);
    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:slotID
                                                            viewController:[UIApplication sharedApplication].adv_getCurrentWindow.rootViewController];

    self.advanceRewardVideo.delegate = self.scapegoat;

    [self.advanceRewardVideo loadAdWithSupplierModel:model];



}

- (BOOL)showAdFromRootViewController:(UIViewController * _Nonnull)viewController parameter:(nonnull NSDictionary *)parameter {
//    NSLog(@"----------->自定义激励视频adapter展示啦加载啦啦<------------");
    self.viewController = viewController;
    
    [self.advanceRewardVideo showAd];

    return YES;
}

- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
}


@end
