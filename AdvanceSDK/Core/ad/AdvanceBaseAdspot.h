//
//  AdvanceBaseAdspot.h
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SdkSupplier.h"

typedef NS_ENUM(NSUInteger, AdvanceSdkSupplierRepoType) {
    /// 发起加载请求上报
    AdvanceSdkSupplierRepoLoaded,
    /// 点击上报
    AdvanceSdkSupplierRepoClicked,
    /// 数据加载成功上报
    AdvanceSdkSupplierRepoSucceeded,
    /// 曝光上报
    AdvanceSdkSupplierRepoImped,
    /// 失败上报
    AdvanceSdkSupplierRepoFaileded,
};

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceBaseAdspotDelegate <NSObject>
@required
/// 加载渠道广告，将会返回渠道所需参数
/// @param sdkId 渠道ID
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkId:(NSString *)sdkId params:(NSDictionary *)params;

@optional
/// 策略请求失败
/// @param error 失败原因
- (void)advanceBaseAdspotFailedWithError:(NSError *)error;


@end

@interface AdvanceBaseAdspot : NSObject

@property (nonatomic, copy) NSString *mediaid;
@property (nonatomic, copy) NSString *adspotid;
@property (nonatomic, strong) NSMutableArray<SdkSupplier *> *suppliers;
@property (nonatomic, strong) SdkSupplier * _Nullable currentSdkSupplier;
/// 策略代理[必填]
@property (nonatomic, weak) id<AdvanceBaseAdspotDelegate> supplierDelegate;
///是否开启策略缓存。注意这里缓存的是SDK的调度策略，而非缓存的广告信息。

@property (nonatomic, assign) BOOL enableStrategyCache;

/// 加载广告
- (void)loadAd;

/// 设置打底渠道
/// @param mediaId mediaId
/// @param adspotId adspotId
/// @param mediaKey mediaKey
/// @param sdkId SDK_ID_XXX
- (void)setDefaultSdkSupplierWithMediaId:(NSString *)mediaId
                                adspotId:(NSString *)adspotId
                                mediaKey:(nullable NSString *)mediaKey
                                  sdkId:(nonnull NSString *)sdkId;

/// 初始化方法
/// @param mediaId mediaId
/// @param adspotId adspotId
- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotId DEPRECATED_MSG_ATTRIBUTE("聚合SDK可以直接使用广告位ID初始化");

/// 初始化方法
/// @param adspotId adspotId
- (instancetype)initWithAdspotId:(NSString *)adspotId;

/// 选择策略(在广告失败后，需手动调用此方法)
- (void)selectSdkSupplierWithError:(NSError * _Nullable)error;

/// 上报
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType;

///

@end
NS_ASSUME_NONNULL_END
