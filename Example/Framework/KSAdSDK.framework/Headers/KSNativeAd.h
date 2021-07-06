//
//  KSNativeAd.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/11.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMaterialMeta.h"
#import "KSAd.h"


NS_ASSUME_NONNULL_BEGIN

@protocol KSNativeAdDelegate;

@interface KSNativeAd : KSAd

/**
 Ad material.
 */
@property (nonatomic, strong, readonly, nullable) KSMaterialMeta *data;

/**
 The delegate for receiving state change messages.
 The delegate is not limited to viewcontroller.
 The delegate can be set to any object which conforming to <KSNativeAdDelegate>.
 */
@property (nonatomic, weak, readwrite, nullable) id<KSNativeAdDelegate> delegate;



/**
 required.
 Root view controller for handling ad actions.
 Action method includes 'pushViewController' and 'presentViewController'.
 */
@property (nonatomic, weak, readwrite) UIViewController *rootViewController;

/**
 Register clickable views in native ads view.
 Interaction types can be configured on TikTok Audience Network.
 Interaction types include view video ad details page, make a call, send email, download the app, open the webpage using a browser,open the webpage within the app, etc.
 @param containerView : required.
 container view of the native ad.
 @param clickableViews : optional.
 Array of views that are clickable.
 */
- (void)registerContainer:(__kindof UIView *)containerView withClickableViews:(NSArray<__kindof UIView *> *_Nullable)clickableViews;
/**
 Unregister ad view from the native ad.
 */
- (void)unregisterView;

- (id)initWithPosId:(NSString *)posId;

/**
 Actively request nativeAd datas.
 */
- (void)loadAdData;

/**
 Actively json nativeAd datas.
 */
- (void)loadAdDataWithDictionary:(NSDictionary *)dictionary;

//- (void)reset;

- (void)reportVideoStartPlay;

- (void)reportVideoEndPlay;

@end



@protocol KSNativeAdDelegate <NSObject>

@optional

/**
 This method is called when native ad material loaded successfully.
 */
- (void)nativeAdDidLoad:(KSNativeAd *)nativeAd;

/**
 This method is called when native ad materia failed to load.
 @param error : the reason of error
 */
- (void)nativeAd:(KSNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error;

/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(KSNativeAd *)nativeAd;

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(KSNativeAd *)nativeAd withView:(UIView *_Nullable)view;

/**
This method is called when another controller has been showed.
@param interactionType : open appstore in app or open the webpage or view video ad details page.
*/
- (void)nativeAdDidShowOtherController:(KSNativeAd *)nativeAd interactionType:(KSAdInteractionType)interactionType;

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeAdDidCloseOtherController:(KSNativeAd *)nativeAd interactionType:(KSAdInteractionType)interactionType;

@end

NS_ASSUME_NONNULL_END
