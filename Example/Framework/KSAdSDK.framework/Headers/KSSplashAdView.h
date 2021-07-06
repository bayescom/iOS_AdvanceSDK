//
//  KSSplashAdView.h
//  KSAdSDK
//
//  Created by zhangchuntao on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import "KSAd.h"

NS_ASSUME_NONNULL_BEGIN

@class KSSplashAdView;

@protocol KSSplashAdViewDelegate <NSObject>
@optional
/**
 * splash ad request done
 */
- (void)ksad_splashAdDidLoad:(KSSplashAdView *)splashAdView;
/**
 * splash ad material load, ready to display
 */
- (void)ksad_splashAdContentDidLoad:(KSSplashAdView *)splashAdView;
/**
 * splash ad (material) failed to load
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didFailWithError:(NSError *)error;
/**
 * splash ad did visible
 */
- (void)ksad_splashAdDidVisible:(KSSplashAdView *)splashAdView;
/**
 * splash ad video begin play
 * for video ad only
 */
- (void)ksad_splashAdVideoDidBeginPlay:(KSSplashAdView *)splashAdView;
/**
 * splash ad clicked
 * @param inMiniWindow whether click in mini window
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didClick:(BOOL)inMiniWindow;
/**
 * splash ad will zoom out, frame can be assigned
 * for video ad only
 * @param frame target frame
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView willZoomTo:(inout CGRect *)frame;
/**
 * splash ad zoomout view will move to frame
 * @param frame target frame
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView willMoveTo:(inout CGRect *)frame;
/**
 * splash ad skipped
 * @param showDuration  splash show duration (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didSkip:(NSTimeInterval)showDuration;
/**
 * splash ad close conversion viewcontroller (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAdDidCloseConversionVC:(KSSplashAdView *)splashAdView interactionType:(KSAdInteractionType)interactType;
/**
 * splash ad play finished & auto dismiss (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAdDidAutoDismiss:(KSSplashAdView *)splashAdView;
/**
 * splash ad close by user (zoom out mode) (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAdDidClose:(KSSplashAdView *)splashAdView;

@end

@interface KSSplashAdView : UIView

@property (nonatomic, weak) id<KSSplashAdViewDelegate> delegate;

@property (nonatomic, weak) UIViewController *rootViewController;
/// max timeout interval, default is 3
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/// need show mini window, default is NO
@property (nonatomic, assign) BOOL needShowMiniWindow;
/// in zoomout state
@property (nonatomic, assign, readonly) BOOL showingMiniWindow;
/// ad interaction type, avaliable after ksad_splashAdContentDidLoad:
@property (nonatomic, assign, readonly) KSAdInteractionType interactionType;
/// ad material type, avaliable after ksad_splashAdContentDidLoad:
@property (nonatomic, assign, readonly) KSAdMaterialType materialType;

- (id)initWithPosId:(NSString *)posId;
/// load ad data
- (void)loadAdData;
/// show splash ad in view, should be called after ksad_splashAdContentDidLoad:
- (void)showInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
