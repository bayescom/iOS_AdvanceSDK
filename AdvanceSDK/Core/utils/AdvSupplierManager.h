//
//  AdvSupplierManager.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>
#import "AdvSupplierModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvSupplierManagerDelegate <NSObject>

// MARK: ======================= 策略回调 =======================

/// 加载策略Model成功
- (void)advSupplierManagerLoadSuccess:(AdvSupplierModel *)model;

/// 加载策略Model失败
- (void)advSupplierManagerLoadError:(NSError *)error;

/// 返回下一个渠道的参数
- (void)advSupplierLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error;


@end

@interface AdvSupplierManager : NSObject

/// 网络请求超时时间（默认: 5秒）
@property (nonatomic, assign) NSTimeInterval fetchTime;


/// 数据加载回调
@property (nonatomic, weak) id<AdvSupplierManagerDelegate> delegate;

/// 设置打底渠道
- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
                                adspotId:(NSString *)adspotid
                                mediaKey:(NSString *)mediakey
                                   sdkId:(nonnull NSString *)sdkid;

/// 数据管理对象
+ (instancetype)manager;

/**
 * 同步数据
 * 如果本地存在有效数据，直接加载本地数据
 * 数据不存在则同步数据
 * @param mediaId 媒体id
 * @param adspotId 广告位id
 * @param ext 自定义拓展字段
 */
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary *_Nonnull)ext;
/**
 * 加载下个渠道
 * 回调 advSupplierLoadSuppluer: error:
 */
- (void)loadNextSupplierIfHas;

/// 数据上报
/// @param repoType 上报的类型
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType error:(NSError *)error;


/// 取消正在进行的策略请求
- (void)cacelDataTask;

@end

NS_ASSUME_NONNULL_END
