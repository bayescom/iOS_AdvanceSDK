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
/// @param sdkTag 渠道Tag
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkTag:(NSString *)sdkTag params:(NSDictionary *)params;

@optional
/// 策略请求失败
/// @param sdkTag 渠道Tag
/// @param error 失败原因
- (void)advanceBaseAdspotWithSdkTag:(NSString *)sdkTag error:(NSError *)error;


@end

@interface AdvanceBaseAdspot : NSObject

@property (nonatomic, copy) NSString *mediaid;
@property (nonatomic, copy) NSString *adspotid;
@property (nonatomic, strong) NSMutableArray<SdkSupplier *> *suppliers;
@property (nonatomic, strong) SdkSupplier * _Nullable currentSdkSupplier;
/// 策略代理[必填]
@property (nonatomic, weak) id<AdvanceBaseAdspotDelegate> supplierDelegate;
@property (nonatomic, assign) BOOL useCache;

/// 加载广告
- (void)loadAd;

/// 设置打底渠道
/// @param mediaId mediaId
/// @param adspotid adspotid
/// @param mediakey mediakey
/// @param sdktag SDK_TAG_XXX
- (void)setDefaultSdkSupplierWithMediaId:(NSString *)mediaId
                                adspotid:(NSString *)adspotid
                                mediakey:(nullable NSString *)mediakey
                                  sdkTag:(nonnull NSString *)sdktag;

/// 初始化方法
/// @param mediaid mediaid
/// @param adspotid adspotid
- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid;

/// 选择策略(在广告失败后，需手动调用此方法)
- (void)selectSdkSupplierWithError:(NSError * _Nullable)error;

/// 上报
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType;

@end
NS_ASSUME_NONNULL_END
