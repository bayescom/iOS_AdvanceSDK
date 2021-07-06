//
//  KSAdSplashViewController.h
//  KSAdSDK
//
//  Created by zhangchuntao on 2020/6/1.
//

#import <UIKit/UIKit.h>
#import "KSVideoAd.h"

NS_ASSUME_NONNULL_BEGIN
DEPRECATED_MSG_ATTRIBUTE("use KSSplashAdView instead.")
@interface KSAdSplashViewController : UIViewController

// 显示方向，需要在viewDidLoad前设置
@property (nonatomic, assign) KSAdShowDirection showDirection;

@end

NS_ASSUME_NONNULL_END
