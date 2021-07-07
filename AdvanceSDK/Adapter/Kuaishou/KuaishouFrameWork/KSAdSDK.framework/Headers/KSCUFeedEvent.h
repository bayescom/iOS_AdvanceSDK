//
//  KSCUEvent.h
//  KSAdSDK
//
//  Created by jie cai on 2021/1/15.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NSString * const KSCUEventName;
/// 滑滑流请求事件名称
extern KSCUEventName  KSCUEventRequestPageAPI;
/*
  滑滑场景类型
 */
typedef NS_ENUM(NSInteger, KSCUFeedEventScene) {
    KSCUFeedEventSceneMainPage,     /// 主滑滑流
    KSCUFeedEventScenePersonalPage, /// 个人作品滑滑流
    KSCUFeedEventSceneOtherPage,    /// 其他类型滑滑流
};

@interface KSCUFeedEvent : NSObject
/// 事件唯一标识符
@property (nonatomic, copy) NSString *eventIdentify;
/// 事件名称
@property (nonatomic, copy) KSCUEventName eventName;
/// 滑滑流场景
@property (nonatomic, assign) KSCUFeedEventScene eventScene;

@end

@interface KSCUResponseObj : NSObject
/// 当前请求视频模型数量
@property (nonatomic, assign) NSInteger countOfVideoInRequest;

@end

NS_ASSUME_NONNULL_END
