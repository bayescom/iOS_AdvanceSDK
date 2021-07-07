//
//  KSCUHotspotPage.h
//  KSAdSDK
//
//  Created by 臧密娜 on 2021/3/10.
//

#import <Foundation/Foundation.h>
#import "KSCUCallBackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class KSCUHotspotPage;
@protocol KSCUContentStateDelegate;
@protocol KSCUVideoStateDelegate;
@protocol KSCUHotspotPageCallBackProtocol;
@protocol KSCUHotspotListRequestCallBackProtocol;

@protocol KSCUHotspotPageCallBackProtocol <KSCUContentPageCallBackProtocol>

@end

@interface KSCUHotspotPageConfig : NSObject
///  视频状态代理
@property (nonatomic, weak) id<KSCUVideoStateDelegate> videoStateDelegate;
///  页面状态代理
@property (nonatomic, weak) id<KSCUContentStateDelegate> stateDelegate;

@property (nonatomic, weak) id<KSCUHotspotPageCallBackProtocol> callBackDelegate;

@property (nonatomic, weak) id<KSCUHotspotListRequestCallBackProtocol> hotspotListRequestDelegate;

@end

@interface KSCUHotspotPage : NSObject

@property (nonatomic, strong, readonly) UIViewController *hotspotViewController;

- (instancetype)initWithPosId:(NSString *)posId configBuilder:(void(^ _Nullable)(KSCUHotspotPageConfig *config) )configBuilder NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 数据请求加载，通过代理回调
/*
  1.连续多次调用,仅第一次生效
  2.回调成功或者失败后,外部自行选择合适时机可以再次调用,进行刷新或重试操作
 */
- (void)refreshData;

/**
 themeMode：0：原样式， 1：媒体自定义样式，如果设置了自定义样式，但是未创建对应的模式配置的plist，默认使用联盟的列表样式
 */
- (void)setThemeMode:(NSInteger)themeMode;

@end

@protocol KSCUHotspotListRequestCallBackProtocol <NSObject>
/// 成功回调通知
- (void)hotspotListSuccessToLoad;
/// 失败回调
- (void)hotspotListFailedToLoadWithError:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
