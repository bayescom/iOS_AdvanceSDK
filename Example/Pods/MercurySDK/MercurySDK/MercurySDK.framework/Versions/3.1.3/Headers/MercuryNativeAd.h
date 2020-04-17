//
//  MercuryNativeAd.h
//  Example
//
//  Created by CherryKing on 2019/11/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MercurySDK/MercurySDK.h>
@class MercuryNativeAdDataModel;
NS_ASSUME_NONNULL_BEGIN

@protocol MercuryNativeAdDelegate <NSObject>

/// 广告数据回调
/// @param nativeAdDataModels 广告数据数组
/// @param error 错误信息
- (void)mercury_nativeAdLoaded:(NSArray<MercuryNativeAdDataModel *> * _Nullable)nativeAdDataModels error:(NSError * _Nullable)error;
@end

@interface MercuryNativeAd : NSObject
@property (nonatomic, weak) id<MercuryNativeAdDelegate> delegate;

/// 构造方法
/// @param adspotId adspotId
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 加载广告
- (void)loadAd;

/// 根据构造方法传入的参数加载广告
/// @param count 需要加载的数据条数
- (void)loadAdWithCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
