//
//  AdvanceAdInfo.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 胜出的渠道广告信息
@interface AdvanceAdInfo : NSObject
@property (nonatomic, copy) NSString *adnId;
@property (nonatomic, copy) NSString *adnName;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) NSInteger biddingType; // 0 非bidding， 1 客户端bidding
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, assign) BOOL fromCache;

@end


@interface AdvRewardVideoModel : NSObject

//app user Identifier
@property (nonatomic, copy, nullable) NSString *userId;

//optional. serialized string.
@property (nonatomic, copy, nullable) NSString *extra;

//reward name.
@property (nonatomic, copy, nullable) NSString *rewardName;

//number of rewards
@property (nonatomic, assign) NSInteger rewardAmount;

@end


@interface AdvRewardCallbackInfo : NSObject
@property (nonatomic, copy) NSString *sourceId; // SDK渠道Id
@property (nonatomic, copy) NSString *rewardName; // 激励名称
@property (nonatomic, assign) NSInteger rewardAmount; // 激励数量

- (instancetype)initWithSourceId:(NSString *)sourceId
                      rewardName:(nullable NSString *)rewardName
                    rewardAmount:(NSInteger)rewardAmount;

@end


typedef NS_ENUM(NSInteger, AdvBidWinLossResultType) {
    AdvBidWinLossResultTypeWin = 0,
    AdvBidWinLossResultTypeLoss = 1
};

@interface AdvBidWinLossResult : NSObject
/// Win/Loss 类型
@property (nonatomic, assign) AdvBidWinLossResultType bidResultType;
/// winPrice
@property (nonatomic, assign) NSInteger winPrice;
/// secondPrice
@property (nonatomic, assign) NSInteger secondPrice;

- (instancetype)initWithBidResultType:(AdvBidWinLossResultType)bidResultType
                             winPrice:(NSInteger )winPrice
                          secondPrice:(NSInteger)secondPrice;

@end

NS_ASSUME_NONNULL_END
