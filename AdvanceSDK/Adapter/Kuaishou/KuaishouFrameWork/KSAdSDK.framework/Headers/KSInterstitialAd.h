//
//  KSInterstitialAd.h
//  KSAdSDK
//
//  Created by zhangchuntao on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import "KSAd.h"

NS_ASSUME_NONNULL_BEGIN

@class KSInterstitialAd;

@protocol KSInterstitialAdDelegate <NSObject>
@optional
/**
 * interstitial ad data loaded
 */
- (void)ksad_interstitialAdDidLoad:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad render success
 */
- (void)ksad_interstitialAdRenderSuccess:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad load or render failed
 */
- (void)ksad_interstitialAdRenderFail:(KSInterstitialAd *)interstitialAd error:(NSError * _Nullable)error;
/**
 * interstitial ad will visible
 */
- (void)ksad_interstitialAdWillVisible:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad did visible
 */
- (void)ksad_interstitialAdDidVisible:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad did skip (for video only)
 * @param playDuration played duration
 */
- (void)ksad_interstitialAd:(KSInterstitialAd *)interstitialAd didSkip:(NSTimeInterval)playDuration;
/**
 * interstitial ad did click
 */
- (void)ksad_interstitialAdDidClick:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad will close
 */
- (void)ksad_interstitialAdWillClose:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad did close
 */
- (void)ksad_interstitialAdDidClose:(KSInterstitialAd *)interstitialAd;
/**
 * interstitial ad did close other controller
 */
- (void)ksad_interstitialAdDidCloseOtherController:(KSInterstitialAd *)interstitialAd interactionType:(KSAdInteractionType)interactionType;

@end

@interface KSInterstitialAd : KSAd

@property (nonatomic, weak) id<KSInterstitialAdDelegate> delegate;

@property (nonatomic, readonly) BOOL isValid;

- (instancetype)initWithPosId:(NSString *)posId;

- (instancetype)initWithPosId:(NSString *)posId containerSize:(CGSize)containerSize;

- (void)loadAdData;

- (void)showFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
