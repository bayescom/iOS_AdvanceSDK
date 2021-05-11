//
//  AdvBaseAdapter.h
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import <Foundation/Foundation.h>
#import "AdvSupplierModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvBaseAdapter : NSObject

/// 并行渠道容器
@property (nonatomic, strong) NSMutableArray * arrParallelSupplier;


/// 聚合媒体Id
@property (nonatomic, copy) NSString *mediaId;

/// 聚合广告位Id
@property (nonatomic, copy) NSString *adspotid;

/// 自定义拓展参数
@property (nonatomic, strong) NSDictionary *ext;


/// 初始化渠道
- (instancetype)initWithMediaId:(nullable NSString *)mediaId
                       adspotId:(nullable NSString *)adspotid;

/// 初始化渠道
/// @param mediaId mediaId
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
- (instancetype)initWithMediaId:(nullable NSString *)mediaId
                       adspotId:(nullable NSString *)adspotid
                      customExt:(NSDictionary *_Nonnull)ext;


/// 加载策略
- (void)loadAd;

/**
 * 加载下个渠道
 */
- (void)loadNextSupplierIfHas;

/// 上报 (已经被废弃)
//- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType;

/// 上报
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(NSError *)error;


/// 取消当前策略请求
- (void)deallocAdapter;

/// 查找一下 容器里有没有并行的渠道
- (id)adapterInParallelsWithSupplier:(AdvSupplier *)supplier;
@end

NS_ASSUME_NONNULL_END
