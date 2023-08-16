//
//  AdvBaseAdapter.h
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
 该类当中的方法与属性 切勿在外部进行操作
 */
@interface AdvanceBaseAdSpot : NSObject

/// 是否上传各渠道版本号 默认为NO
@property (nonatomic, assign) BOOL isUploadSDKVersion;

/// 并行渠道容器
@property (nonatomic, strong) NSMutableArray *arrParallelSupplier;

/// 各渠道错误的详细原因
@property (nonatomic, strong) NSMutableDictionary *errorDescriptions;

/// 聚合媒体Id / appId
@property (nonatomic, copy) NSString *mediaId;

/// 聚合广告位Id
@property (nonatomic, copy) NSString *adspotid;

/// 自定义拓展参数
@property (nonatomic, strong) NSDictionary *ext;

/// 广告加载容器视图
@property (nonatomic, weak) UIViewController *viewController;

/// 初始化渠道
/// @param mediaId mediaId
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
- (instancetype)initWithMediaId:(nullable NSString *)mediaId
                       adspotId:(nullable NSString *)adspotid
                      customExt:(nullable NSDictionary *)ext;

/// 加载策略
- (void)loadAd;

/// 加载策略
- (void)loadAdWithSupplierModel:(AdvPolicyModel *)model;

/// 加载下个渠道
- (void)loadNextSupplierIfHas;

/// 上报
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(NSError *)error;

/// 取消当前策略请求
- (void)deallocAdapter DEPRECATED_MSG_ATTRIBUTE("该方法在AdvanceSDK内部调用, 开发者不要手动调用该方法, 如想释放,只需把广告对象置为nil即可");

/// 查找一下 容器里有没有并行的渠道
- (id)adapterInParallelsWithSupplier:(AdvSupplier *)supplier;

/**
 该类当中的方法与属性 切勿在外部进行操作
 */

@end

NS_ASSUME_NONNULL_END
