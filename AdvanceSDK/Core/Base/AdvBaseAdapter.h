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

/// 初始化渠道
- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotid;

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

/// 上报
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType;


@end

NS_ASSUME_NONNULL_END