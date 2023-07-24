//
//  AdvSupplierManager.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>
#import "AdvSupplierModel.h"
#import "AdvanceSupplierDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceSupplierDelegate;

@interface AdvSupplierManager : NSObject

/// 网络请求超时时间（默认: 5秒）
@property (nonatomic, assign) NSTimeInterval fetchTime;

@property (nonatomic, weak) id<AdvanceSupplierDelegate> delegate;

/// 数据管理对象
+ (instancetype)manager;

/**
 * 获取策略数据
 * 如果本地存在有效数据，直接加载本地数据
 * 数据不存在则网络获取数据
 * @param mediaId 媒体id
 * @param adspotId 广告位id
 * @param ext 自定义拓展字段
 */
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary *_Nonnull)ext;

/// 加载策略
- (void)loadDataWithSupplierModel:(AdvSupplierModel *)model;

/**
 * 加载下个渠道
 * 回调 advSupplierLoadSuppluer: error:
 */
- (void)loadNextSupplierIfHas;

/**
 * 加载下一层bidding
 * 回调 advSupplierLoadSuppluer: error:
 */
- (void)loadNextWaterfallSupplierIfHas;

/// 数据上报
/// @param repoType 上报的类型
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(NSError *)error;


/// 取消正在进行的策略请求
- (void)cancelDataTask;

/// 进入bidding队列
- (void)inWaterfallQueueWithSupplier:(AdvSupplier *)supplier;

// 进入HeadBidding队列
- (void)inHeadBiddingQueueWithSupplier:(AdvSupplier *)supplier;

// 接收失败的并发渠道
- (void)inParallelWithErrorSupplier:(AdvSupplier *)errorSupplier;

@end

NS_ASSUME_NONNULL_END
