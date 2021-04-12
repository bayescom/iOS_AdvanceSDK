//
//  AdvSupplierQueue.h
//  AdvanceSDK
//
//  Created by MS on 2021/1/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@interface AdvSupplierQueue : NSObject
@property (nonatomic, strong) NSMutableArray<AdvSupplier *> *inQueueSuppliers;
@end

NS_ASSUME_NONNULL_END
