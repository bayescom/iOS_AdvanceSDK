//
//  KSCUFeedPage.h
//  KSAdSDK
//
//  Created by jie cai on 2020/9/2.
//

#import <Foundation/Foundation.h>
#import "KSCUOuterController.h"
#import "KSCUContentPageDelegate.h"
#import "KSCUCallBackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSCUFeedPage : NSObject

/*
   属性配置,需要在获取 feedViewController前设置
 */
///跳转是否隐藏 TarBar,默认为 YES
@property(nonatomic, assign) BOOL hidesBottomBarWhenPushed;
///  视频状态代理
@property (nonatomic, weak) id<KSCUVideoStateDelegate> videoStateDelegate;
///  页面状态代理
@property (nonatomic, weak) id<KSCUContentStateDelegate> stateDelegate;

@property (nonatomic, weak) id<KSCUFeedPageCallBackProtocol> callBackDelegate;

@property (nonatomic, readonly) UIViewController *feedViewController;

@property (nonatomic, strong) KSCUOuterController *outerController;

- (instancetype)initWithPosId:(NSString *)posId NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/**
 设置夜间模式和非夜间模式
 themeMode：0：原样式， 1：夜间模式，如果设置了夜间模式，但是未创建夜间模式配置的plist，默认使用联盟的夜间页面
 */
- (void)setThemeMode:(NSInteger)themeMode;

@end

NS_ASSUME_NONNULL_END
