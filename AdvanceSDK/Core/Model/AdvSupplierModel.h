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

@property (nonatomic, assign) NSTimeInterval cacheTime;

@end

@interface AdvSupplier : NSObject
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *sdktag;
@property (nonatomic, copy)   NSString *mediakey;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, copy)   NSString *adspotid;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *mediaid;
@property (nonatomic, assign) NSInteger priority;
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
