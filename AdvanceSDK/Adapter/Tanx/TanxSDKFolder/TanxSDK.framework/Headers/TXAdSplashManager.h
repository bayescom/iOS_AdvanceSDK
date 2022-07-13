//
//  TXAdSplashManager.h
//  TanxSDK
//
//  Created by XY on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TanxSDK/TXAdSplashManagerDelegate.h>
#import <TanxSDK/TXAdSplashModel.h>
#import <TanxSDK/TXAdSplashTemplateConfig.h>


typedef void(^TXAdGetSplashAdBlock)(NSArray <TXAdSplashModel *> * _Nullable splashModels, NSError * _Nullable error);

typedef void(^TXAdGetSplashTemplateBlock)(UIView * _Nullable template, NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface TXAdSplashManager : NSObject

@property (nonatomic, assign) NSUInteger retryCount;        //请求出错后最大支持的重试次数
@property (nonatomic, assign) NSTimeInterval waitSyncTimeout;    //允许开屏请求最长时间(推荐设置3秒)
@property (nonatomic, weak) id<TXAdSplashManagerDelegate> delegate;     //代理需要实现的协议

/// 发起获取开屏广告请求
/// @param block 返回广告数据（@媒体可获取通过TXAdSplashModel的ecpm获取报价，若为空则表明该媒体没有获取权限）
/// @param pid 广告pid
- (void)getSplashAdsWithBlock:(TXAdGetSplashAdBlock)block withPid:(NSString * __nonnull)pid;

/// 预请求，建议在开屏展示完毕后再发起请求
/// @param pid 广告pid
- (void)preGetSplashAdWithPid:(NSString * __nonnull)pid;

/// 上报竞价成功
/// @param model 数据
/// @param result 结果YES/NO
- (void)uploadBidding:(TXAdSplashModel *)model isWin:(BOOL)result;

/// 通过广告数据获取开屏广告模板（媒体如果参竞，上报竞价后调用）
/// @param model 开屏广告数据
- (UIView *)renderSplashTemplateWithModel:(TXAdSplashModel *)model config:(TXAdSplashTemplateConfig *)config;


///无竞价，直接获取开屏广告模板
/// @param block 返回广告模板
/// @param pid 广告pid
- (void)getSplashTemplateWithBlock:(TXAdGetSplashTemplateBlock)block withPid:(NSString * __nonnull)pid;

/// 删除本地缓存的开屏素材
/// @param finishBlock block
- (void)removeLocalMaterials:(_Nullable dispatch_block_t)finishBlock;

/// 删除缓存JSON数据
- (void)removeLocalData;

/// 移除开屏的所有缓存
- (void)removeLocalAssets;


@end

NS_ASSUME_NONNULL_END
