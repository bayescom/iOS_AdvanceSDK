//
//  AdvBidWinLossResult.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/25.
//

#import "AdvBidWinLossResult.h"

@implementation AdvBidWinLossResult

- (instancetype)initWithBidResultType:(AdvBidWinLossResultType)bidResultType winPrice:(NSInteger)winPrice secondPrice:(NSInteger)secondPrice {
    if (self = [super init]) {
        self.bidResultType = bidResultType;
        self.winPrice = winPrice;
        self.secondPrice = secondPrice;
    }
    return self;
}

@end
