//
//  AdvanceBaseAdspot.h
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SdkSupplier.h"

NS_ASSUME_NONNULL_BEGIN


@interface AdvanceBaseAdspot : NSObject

@property(nonatomic, copy) NSString *mediaid;
@property(nonatomic, copy) NSString *adspotid;
@property(nonatomic, strong) NSMutableArray<SdkSupplier *> *suppliers;
@property(nonatomic, strong) SdkSupplier *currentSdkSupplier;
@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) BOOL useCache;

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

NS_ASSUME_NONNULL_END
@end
