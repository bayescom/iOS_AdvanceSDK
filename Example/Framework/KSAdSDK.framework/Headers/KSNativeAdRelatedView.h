//
//  KSNativeAdRelatedView.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/16.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSVideoAdView.h"
#import "KSNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSNativeAdRelatedView : NSObject

/**
 Promotion label.Need to actively add to the view.
 */
@property (nonatomic, strong, readonly, nullable) UILabel *adLabel;


/**
 Video ad view. Need to actively add to the view.
 */
@property (nonatomic, strong, readonly, nullable) KSVideoAdView *videoAdView;

/**
 Refresh the data every time you get new datas in order to show ad perfectly.
 */
- (void)refreshData:(KSNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
