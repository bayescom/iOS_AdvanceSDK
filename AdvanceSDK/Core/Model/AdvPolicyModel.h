//
//  AdvPolicyModel.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>

@class AdvPolicyModel;
@class AdvSetting;
@class AdvSupplier;
@class Gro_more;
@class Gmtk;
@class Gromore_params;

typedef NS_ENUM(NSUInteger, AdvanceSdkSupplierRepoType) {
    /// 发起加载请求上报
    AdvanceSdkSupplierRepoLoaded,
    /// 点击上报
    AdvanceSdkSupplierRepoClicked,
    /// 数据加载成功上报
    AdvanceSdkSupplierRepoSucceed,
    /// 曝光上报
    AdvanceSdkSupplierRepoImped,
    /// 广告加载/渲染失败上报
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

typedef NS_ENUM(NSUInteger, AdvanceSupplierLoadAdState) {
    
    /// 准备就绪
    AdvanceSupplierLoadAdReady = 0,
    /// 渠道请求广告素材成功
    AdvanceSupplierLoadAdSuccess,
    /// 渠道请求广告素材失败
    AdvanceSupplierLoadAdFailed,
    /// 渠道请求广告素材超时
    AdvanceSupplierLoadAdTimeout,

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

@interface AdvPolicyModel : NSObject
@property (nonatomic, strong) Gro_more  *gro_more;
@property (nonatomic, strong) AdvSetting *setting;
@property (nonatomic, strong) NSMutableArray<AdvSupplier *> *suppliers;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *reqid;


//@property (nonatomic, copy)   NSString *advMediaId;
//@property (nonatomic, copy)   NSString *advAdspotId;


@end

// 上游/渠道SDK对象
@interface AdvSupplier : NSObject
@property (nonatomic, copy) NSString *identifier; /// 上游sdk id
@property (nonatomic, copy) NSString *name; /// 上游sdk名称
@property (nonatomic, copy) NSString *sdktag; /// 上游sdk标识
@property (nonatomic, copy) NSString *mediakey; /// 媒体key
@property (nonatomic, copy) NSString *mediaid; /// 媒体id
@property (nonatomic, copy) NSString *mediasecret; /// 媒体秘钥
@property (nonatomic, assign) NSInteger priority; /// 上游sdk优先级，数值越小优先级越高 最高为1
@property (nonatomic, assign) NSInteger timeout; /// 上游sdk请求超时时间（ms）
@property (nonatomic, copy) NSString *adspotid; /// 上游sdk分配给媒体的广告位id
@property (nonatomic, assign) NSInteger sdk_price; /// 单位: 分

/// 此渠道广告是否勾选了头部竞价 1-是 0-否，如果该渠道SDK支持head_bidding，则去获取竞价
@property (nonatomic, assign) NSInteger is_head_bidding;
/// 竞价sdk用于和GroMore比价时的加强系数, 目前全是 1
@property (nonatomic, assign) CGFloat bidRatio;
/// 穿山甲开屏，1代表使用旧API加载开屏广告，其他代表使用新API，默认使用新API。
@property (nonatomic, assign) NSInteger versionTag;

@property (nonatomic, strong) NSArray<NSString *> *clicktk;
@property (nonatomic, strong) NSArray<NSString *> *loadedtk;
@property (nonatomic, strong) NSArray<NSString *> *imptk;
@property (nonatomic, strong) NSArray<NSString *> *succeedtk;
@property (nonatomic, strong) NSArray<NSString *> *failedtk;
@property (nonatomic, strong) NSArray<NSString *> *biddingtk;/// gro_more使用

/// 上游sdk竞胜上报（仅在开启竞价情况下返回）。SDK调用时机为，发起广告展现方法时
@property (nonatomic, strong) NSArray<NSString *> *wintk;


/// 该字段由各渠道SDK 返回并填充 用来做比价
/// GDT 单位:分   成功返回一个大于等于0的值，-1表示无权限或后台出现异常
@property (nonatomic, assign) NSInteger supplierPrice;
@property (nonatomic, assign) BOOL isParallel;// 是否并行
@property (nonatomic, assign) AdvanceSdkSupplierState state;// 渠道状态
@property (nonatomic, assign) AdvanceSdkSupplierBiddingType positionType;

@property (nonatomic, assign) AdvanceSupplierLoadAdState loadAdState; // 广告加载状态
@property (nonatomic, assign) BOOL hited; // 是否已经命中过

@end

// 全局配置信息
@interface AdvSetting : NSObject
/// 1:使用缓存模式加载策略，其他使用实时策略
@property (nonatomic, assign) NSInteger useCache;
/// 策略缓存时长
@property (nonatomic, assign) NSInteger cacheDur;
/// 聚合竞价模式：0表示普通竞价，1 为 GroMore 竞价
@property (nonatomic, assign) NSInteger bidding_type;
/// SDK并行请求总体超时时长(ms)
@property (nonatomic, assign) NSInteger parallel_timeout;
/// 并行策略组，该字段返回值为int型二维数组，每一组代表组内对应优先级的渠道需要并行，各个组之间需要串行
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *parallelGroup;
/// 需要进行headbidding的渠道SDK （存放is_head_bidding = 1 的 suppliers）
@property (nonatomic, strong) NSMutableArray<NSNumber *> *headBiddingGroup;

@end


// gro_more对象
@interface Gro_more :NSObject
@property (nonatomic, strong) Gmtk              *gmtk;
@property (nonatomic, strong) Gromore_params    *gromore_params;

@end

// gro_more的上报链接
@interface Gmtk :NSObject
@property (nonatomic, strong) NSArray <NSString *>  * failedtk;
@property (nonatomic, strong) NSArray <NSString *>  * imptk;
@property (nonatomic, strong) NSArray <NSString *>  * biddingtk;
@property (nonatomic, strong) NSArray <NSString *>  * succeedtk;
@property (nonatomic, strong) NSArray <NSString *>  * clicktk;
@property (nonatomic, strong) NSArray <NSString *>  * loadedtk;

@end

// gro_more的配置参数
@interface Gromore_params :NSObject
@property (nonatomic, copy) NSString     * appid;
@property (nonatomic, copy) NSString     * adspotid;
@property (nonatomic, assign) NSInteger    timeout;

@end

NS_ASSUME_NONNULL_END
