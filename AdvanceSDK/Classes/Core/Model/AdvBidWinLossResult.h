//
//  AdvBidWinLossResult.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
