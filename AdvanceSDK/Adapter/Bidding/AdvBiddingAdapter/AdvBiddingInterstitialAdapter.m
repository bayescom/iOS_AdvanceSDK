//
//  AdvBiddingInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2023/3/27.
//

#import "AdvBiddingInterstitialAdapter.h"
#import "AdvSupplierModel.h"
#import "AdvanceInterstitial.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif
#import "AdvLog.h"

@interface AdvBiddingInterstitialAdapter ()<ABUInterstitialAdDelegate>
@property (nonatomic, strong) ABUInterstitialAd *interstitialAd;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation AdvBiddingInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        
        self.interstitialAd = [[ABUInterstitialAd alloc] initWithAdUnitID:supplier.adspotid size:_adspot.adSize];
        self.interstitialAd.delegate = self;
        self.interstitialAd.mutedIfCan = YES;

    }
    return self;
}

@end
