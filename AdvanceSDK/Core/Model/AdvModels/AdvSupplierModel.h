//
//  AdvSupplierModel.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>

@class AdvSupplierModel;
@class AdvSetting;
@class AdvSupplier;
@class AdvPriorityMap;
@class AdvBiddingModel;
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
    
    /// bidding上报 目前未使用
    AdvanceSdkSupplierRepoBidding

};

typedef NS_ENUM(NSUInteger, AdvanceSdkSupplierState) {
    /// 未知
    AdvanceSdkSupplierStateUnknown,
    /// 准备就绪
    AdvanceSdkSupplierStateReady,
    /// 渠道请求成功(只是请求成功 不是曝光成功)
    AdvanceSdkSupplierStateSuccess,
    /// 渠道请求失败
    AdvanceSdkSupplierStateFailed,
    /// 渠道进行中(广告发起请求前)
    AdvanceSdkSupplierStateInHand,
    
    /// 广告请求进行中(广告发起请求后到结果确定前)
    AdvanceSdkSupplierStateInPull,

};

NS_ASSUME_NONNULL_BEGIN

NSString * ADVStringFromNAdvanceSdkSupplierRepoType(AdvanceSdkSupplierRepoType type);

#pragma mark - Object interfaces

@interface AdvSupplierModel : NSObject
@property (nonatomic, strong) AdvSetting *setting;
@property (nonatomic, strong)   NSMutableArray<AdvSupplier *> *suppliers;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy)   NSString *reqid;

@property (nonatomic, copy)   NSString *advMediaId;
@property (nonatomic, copy)   NSString *advAdspotId;


/// 从本地查找数据
+ (instancetype)loadDataWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId;

/// 移除本地缓存数据
- (void)clearLocalModel;

/// 存储到本地
- (void)saveData:(NSData *)data;

@end

@interface AdvSetting : NSObject
@property (nonatomic, assign) NSInteger useCache;
@property (nonatomic, assign) NSInteger cacheDur;
@property (nonatomic, copy)   NSString *cptStart;
@property (nonatomic, copy)   NSString *cptEnd;
@property (nonatomic, copy)   NSString *cptSupplier;
@property (nonatomic, assign) BOOL isBidding; // 策略告知是本次是否有bidding渠道, 这个字段决定了parallelGroup 拿到第一组优先级后 是否走bidding逻辑
@property (nonatomic, copy)   NSArray<NSString *> *parallelIDS;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *parallelGroup;
@property (nonatomic, assign) NSTimeInterval cacheTime;


@property (nonatomic , assign) NSInteger bidding_type;
@property (nonatomic , assign) NSInteger parallel_timeout;
@property (nonatomic , strong) AdvBiddingModel *gromore_params;


@end

@interface AdvBiddingModel : NSObject
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, copy)   NSString *appid;
@property (nonatomic, copy)   NSString *adspotid;

@end



@interface AdvSupplier : NSObject
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *sdktag;
@property (nonatomic, assign) NSInteger versionTag;// 默认0或者-1是最新的   2是最新的 1是旧版本 
@property (nonatomic, copy)   NSString *mediakey;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, copy)   NSString *adspotid;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *mediaid;
@property (nonatomic, assign) NSInteger sdk_price;// 单位: 分
@property (nonatomic, assign) NSInteger priority;

/// 该字段由各渠道SDK 返回并填充 用来做比价
/// GDT 单位:分   成功返回一个大于等于0的值，-1表示无权限或后台出现异常
@property (nonatomic, assign) NSInteger supplierPrice;

@property (nonatomic, assign) BOOL isParallel;// 是否并行
@property (nonatomic, assign) AdvanceSdkSupplierState state;// 渠道状态
@property (nonatomic, copy)   NSArray<NSString *> *clicktk;
@property (nonatomic, copy)   NSArray<NSString *> *loadedtk;
@property (nonatomic, copy)   NSArray<NSString *> *imptk;
@property (nonatomic, copy)   NSArray<NSString *> *succeedtk;
@property (nonatomic, copy)   NSArray<NSString *> *failedtk;
@property (nonatomic, assign) BOOL isSupportBidding;


/// 构建打底渠道
//+ (instancetype)supplierWithMediaId:(NSString *)mediaId
//                           adspotId:(NSString *)adspotid
//                           mediaKey:(NSString *)mediakey
//                              sdkId:(nonnull NSString *)sdkid;

@end


NS_ASSUME_NONNULL_END
