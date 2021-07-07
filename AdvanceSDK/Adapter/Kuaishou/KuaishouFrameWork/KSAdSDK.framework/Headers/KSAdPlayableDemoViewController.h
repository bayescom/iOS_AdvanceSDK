//
//  KSAdPlayableDemoViewController.h
//  KSAdSDK
//
//  Created by zhangchuntao on 2020/11/20.
//

#import <UIKit/UIKit.h>
#import "KSVideoAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSAdPlayableDemoViewController : UIViewController

@property (nonatomic, copy) NSString *playableURL;

@property (nonatomic, copy) NSString *downloadURL;

@property (nonatomic, assign) KSAdShowDirection showDirection;

@end

NS_ASSUME_NONNULL_END
