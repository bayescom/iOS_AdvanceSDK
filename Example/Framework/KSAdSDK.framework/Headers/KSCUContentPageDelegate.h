//
//  KSCUVideoDelegate.h
//  Pods
//
//  Created by zhangchuntao on 2020/5/14.
//

#ifndef KSCUVideoDelegate_h
#define KSCUVideoDelegate_h

typedef NS_ENUM(NSUInteger, KSCUContentType) {
    KSCUContentTypeUnknown,         //未知，正常不会出现
    KSCUContentTypeNormal,          //普通信息流
    KSCUContentTypeAd,              //SDK内部广告
    KSCUContentTypeEmbeded = 100    //外部广告
};

@protocol KSCUContentInfo <NSObject>

//内容标识
- (NSString *)publicContentId;
//内容类型
- (KSCUContentType)publicContentType;
//视频时长. 毫秒
- (NSTimeInterval)publicVideoDuration;

@end

/**
 * 视频播放状态代理
 */
@protocol KSCUVideoStateDelegate <NSObject>
@optional
/**
 * 视频开始播放
 * @param videoContent 内容模型
 */
- (void)kscu_videoDidStartPlay:(id<KSCUContentInfo>)videoContent;
/**
* 视频暂停播放
* @param videoContent 内容模型
*/
- (void)kscu_videoDidPause:(id<KSCUContentInfo>)videoContent;
/**
* 视频恢复播放
* @param videoContent 内容模型
*/
- (void)kscu_videoDidResume:(id<KSCUContentInfo>)videoContent;
/**
* 视频停止播放
* @param videoContent 内容模型
* @param finished     是否播放完成
*/
- (void)kscu_videoDidEndPlay:(id<KSCUContentInfo>)videoContent isFinished:(BOOL)finished;
/**
* 视频播放失败
* @param videoContent 内容模型
* @param error        失败原因
*/
- (void)kscu_videoDidFailedToPlay:(id<KSCUContentInfo>)videoContent withError:(NSError *)error;

@end


/**
* 内容展示状态代理
*/
@protocol KSCUContentStateDelegate <NSObject>
@optional
/**
* 内容展示
* @param content 内容模型
*/
- (void)kscu_contentDidFullDisplay:(id<KSCUContentInfo>)content;
/**
* 内容隐藏
* @param content 内容模型
*/
- (void)kscu_contentDidEndDisplay:(id<KSCUContentInfo>)content;
/**
* 内容暂停显示，ViewController disappear或者Application resign active
* @param content 内容模型
*/
- (void)kscu_contentDidPause:(id<KSCUContentInfo>)content;
/**
* 内容恢复显示，ViewController appear或者Application become active
* @param content 内容模型
*/
- (void)kscu_contentDidResume:(id<KSCUContentInfo>)content;

@end


#endif /* KSCUVideoDelegate_h */
