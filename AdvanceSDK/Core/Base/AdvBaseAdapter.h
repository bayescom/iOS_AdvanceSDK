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


/// 设置打底渠道
- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
                                adspotId:(NSString *)adspotid
                                mediaKey:(NSString *)mediakey
                                   sdkId:(nonnull NSString *)sdkid;

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

/// 执行了打底渠道
- (void)advSupplierLoadDefaultSuppluer:(AdvSupplier *)supplier;
@end

NS_ASSUME_NONNULL_END
