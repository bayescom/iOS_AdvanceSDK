//
//  AdvBiddingInterstitialCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2023/3/29.
//

#import "AdvBiddingInterstitialCustomAdapter.h"
#import <AdvanceSDK/AdvanceInterstitial.h>
#import "AdvBiddingInterstitialScapegoat.h"
#import "AdvBiddingCongfig.h"
#import "AdvSupplierModel.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
@interface AdvBiddingInterstitialCustomAdapter ()
@property (nonatomic, strong) AdvBiddingInterstitialScapegoat *scapegoat;

@property (nonatomic, strong) AdvanceInterstitial *interstitialAd;

@end

@implementation AdvBiddingInterstitialCustomAdapter
- (AdvBiddingInterstitialScapegoat *)scapegoat {
    if (_scapegoat == nil) {
        _scapegoat = [[AdvBiddingInterstitialScapegoat alloc]init];
        _scapegoat.a = self;
    }
    return _scapegoat;
}

- (void)loadInterstitialAdWithSlotID:(NSString *)slotID andSize:(CGSize)size parameter:(NSDictionary *)parameter {
    NSLog(@"1111===> %@", NSStringFromCGSize(size));
    [self _setupWithWithSlotID:slotID adSize:size andParameter:parameter];
    
    if (self.interstitialAd) {
        AdvSupplierModel *model = [[AdvBiddingCongfig defaultManager] returnSupplierByAdspotId:slotID];
        [self.interstitialAd loadAdWithSupplierModel:model];
    } else {
        [self.bridge interstitialAd:self didLoadFailWithError:nil ext:@{}];
    }

}

- (BOOL)showAdFromRootViewController:(UIViewController *)viewController parameter:(NSDictionary *)parameter {
    if (self.interstitialAd) {
        [self.interstitialAd showAd];
    } else {
        [self.bridge interstitialAdDidShowFailed:self error:nil];
        return NO;
    }
    
    return YES;
}


#pragma mark - Private
- (void)_setupWithWithSlotID:(NSString *)slotID adSize:(CGSize)adSize andParameter:(NSDictionary *)parameter {
    // 非模板或者较新版本不区分模板类，统一使用一个类
        self.interstitialAd = [[AdvanceInterstitial alloc] initWithAdspotId:slotID
                                                             viewController:[UIApplication sharedApplication].adv_getCurrentWindow.rootViewController
                                                                     adSize:adSize];
        
        // ↓↓↓ 尽量不要使用adapter作为接收adn广告的delegate对象，可传入包装类用于接收adn的广告回调 ↓↓↓
        [self.interstitialAd setDelegate:self.scapegoat];
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
    self.interstitialAd = nil;
}

@end
