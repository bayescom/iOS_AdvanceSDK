//
//  AdvanceSplash.h
//  Demo
//
//  Created by CherryKing on 2020/11/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvBaseAdapter.h"
#import "AdvSdkConfig.h"
#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceSplash : AdvBaseAdapter

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

/// 是否必须展示Logo 默认: NO
@property (nonatomic, assign) BOOL showLogoRequire;

/// 广告Logo
/// 当 showLogoRequire = YES时, 必须设置logoImage
@property(nonatomic, strong) UIImage *logoImage;

/// 广告未加载出来时的占位图
@property(nonatomic, strong) UIImage *backgroundImage;

/// 控制器
@property(nonatomic, weak) UIViewController *viewController;

/// 总超时时间
/// 如果使用bidding 功能 timeout时长必须要比 服务器下发的bidding等待时间要长 否则会严重影响变现效率
@property (nonatomic, assign) NSInteger timeout;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController;


/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(NSDictionary *_Nonnull)ext
                  viewController:(UIViewController *)viewController;

- (void)ddddd;

@end

NS_ASSUME_NONNULL_END
