//
//  AdvBiddingCongfig.h
//  
//
//  Created by MS on 2022/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AdvSupplierModel;
@interface AdvBiddingCongfig : NSObject
+ (AdvBiddingCongfig *)defaultManager;
@property (nonatomic, strong) AdvSupplierModel *adDataModel;

// 清空持有的adDataModel
- (void)deleteAdDataModel;
@end

NS_ASSUME_NONNULL_END
