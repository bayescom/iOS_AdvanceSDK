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
@class Gro_more;
@class Gmtk;
@class Gromore_params;

typedef NS_ENUM(NSUInteger, AdvanceSdkSupplierRepoType) {
    /// 发起加载请求上报
    AdvanceSdkSupplierRepoLoaded,
    /// 点击上报
    AdvanceSdkSupplierRepoClicked,
    /// 数据加载成功上报v
    AdvanceSdkSupplierRepoSucceed,
    /// 曝光上报
    AdvanceSdkSupplierRepoImped,
    /// 失败上报
    AdvanceSdkSupplierRepoFailed,
    /// bidding结果上报
    AdvanceSdkSupplierRepoBidding,
    /// bidding广告位生命周期上报
    AdvanceSdkSupplierRepoGMBidding

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

typedef NS_ENUM(NSUInteger, AdvanceSdkSupplierBiddingType) {
    /// 瀑布流式
    AdvanceSdkSupplierTypeWaterfall,
    /// headBidding头部竞价
    AdvanceSdkSupplierTypeHeadBidding,
};


NS_ASSUME_NONNULL_BEGIN

NSString * ADVStringFromNAdvanceSdkSupplierRepoType(AdvanceSdkSupplierRepoType type);

#pragma mark - Object interfaces

@interface AdvSupplierModel : NSObject
@property (nonatomic, strong) Gro_more  *gro_more;
@property (nonatomic, strong) AdvSetting *setting;
@property (nonatomic, strong) NSMutableArray<AdvSupplier *> *suppliers;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy)   NSString *reqid;

@property (nonatomic, copy)   NSString *advMediaId;
@property (nonatomic, copy)   NSString *advAdspotId;


@end

@interface AdvSetting : NSObject
@property (nonatomic, assign) NSInteger useCache;
@property (nonatomic, assign) NSInteger cacheDur;
@property (nonatomic, copy)   NSString *cptStart;
@property (nonatomic, copy)   NSString *cptEnd;
@property (nonatomic, copy)   NSString *cptSupplier;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *parallelGroup;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *headBiddingGroup;
@property (nonatomic, assign) NSTimeInterval cacheTime;


@property (nonatomic , assign) NSInteger bidding_type;
@property (nonatomic , assign) NSInteger parallel_timeout;
@property (nonatomic , strong) AdvBiddingModel *gromore_params;
@property (nonatomic , strong) NSArray<NSString *> *gmtk;


@end

@interface AdvBiddingModel : NSObject
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, copy)   NSString *appid;
@property (nonatomic, copy)   NSString *adspotid;

@end

@interface Gmtk :NSObject
@property (nonatomic , strong) NSArray <NSString *>              * failedtk;
@property (nonatomic , strong) NSArray <NSString *>              * imptk;
@property (nonatomic , strong) NSArray <NSString *>              * biddingtk;
@property (nonatomic , strong) NSArray <NSString *>              * succeedtk;
@property (nonatomic , strong) NSArray <NSString *>              * clicktk;
@property (nonatomic , strong) NSArray <NSString *>              * loadedtk;

@end


@interface Gromore_params :NSObject
@property (nonatomic , copy) NSString              * appid;
@property (nonatomic , copy) NSString              * adspotid;
@property (nonatomic , assign) NSInteger              timeout;

@end


@interface Gro_more :NSObject
@property (nonatomic , strong) Gmtk              *gmtk;
@property (nonatomic , strong) Gromore_params    *gromore_params;

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
@property (nonatomic, strong)   NSArray<NSString *> *clicktk;
@property (nonatomic, strong)   NSArray<NSString *> *loadedtk;
@property (nonatomic, strong)   NSArray<NSString *> *imptk;
@property (nonatomic, strong)   NSArray<NSString *> *succeedtk;
@property (nonatomic, strong)   NSArray<NSString *> *failedtk;
@property (nonatomic, strong)   NSArray<NSString *> *biddingtk;// 只有gm使用

@property (nonatomic, assign) AdvanceSdkSupplierBiddingType positionType;


/// 构建打底渠道
//+ (instancetype)supplierWithMediaId:(NSString *)mediaId
//                           adspotId:(NSString *)adspotid
//                           mediaKey:(NSString *)mediakey
//                              sdkId:(nonnull NSString *)sdkid;

@end


NS_ASSUME_NONNULL_END