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
@property (nonatomic, copy)   NSArray<AdvSupplier *> *suppliers;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy)   NSString *reqid;

@property (nonatomic, copy)   NSString *advMediaId;
@property (nonatomic, copy)   NSString *advAdspotId;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;

/// 从本地查找数据
+ (instancetype)loadDataWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId;

/// 移除本地缓存数据
- (void)clearLocalModel;

/// 存储到本地
- (void)save;

@end

@interface AdvSetting : NSObject
@property (nonatomic, assign) NSInteger useCache;
@property (nonatomic, assign) NSInteger cacheDur;
@property (nonatomic, copy)   NSString *cptStart;
@property (nonatomic, copy)   NSString *cptEnd;
@property (nonatomic, copy)   NSString *cptSupplier;
@property (nonatomic, copy)   NSArray<NSString *> *parallelIDS;
@property (nonatomic, copy)   NSArray<AdvPriorityMap *> *priorityMap;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *parallelGroup;
@property (nonatomic, assign) NSTimeInterval cacheTime;

@end

@interface AdvPriorityMap : NSObject
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, copy)   NSString *supid;
@end

@interface AdvSupplier : NSObject
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *sdktag;
@property (nonatomic, assign) NSInteger versionTag;
@property (nonatomic, copy)   NSString *mediakey;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, copy)   NSString *adspotid;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *mediaid;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) BOOL isParallel;// 是否并行
@property (nonatomic, assign) AdvanceSdkSupplierState state;// 渠道状态
@property (nonatomic, copy)   NSArray<NSString *> *clicktk;
@property (nonatomic, copy)   NSArray<NSString *> *loadedtk;
@property (nonatomic, copy)   NSArray<NSString *> *imptk;
@property (nonatomic, copy)   NSArray<NSString *> *succeedtk;
@property (nonatomic, copy)   NSArray<NSString *> *failedtk;


/// 构建打底渠道
+ (instancetype)supplierWithMediaId:(NSString *)mediaId
                           adspotId:(NSString *)adspotid
                           mediaKey:(NSString *)mediakey
                              sdkId:(nonnull NSString *)sdkid;

@end

NS_ASSUME_NONNULL_END
