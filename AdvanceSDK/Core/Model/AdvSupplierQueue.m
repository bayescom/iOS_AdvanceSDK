//
//  AdvSupplierQueue.m
//  AdvanceSDK
//
//  Created by MS on 2021/1/26.
//

#import "AdvSupplierQueue.h"

@implementation AdvSupplierQueue
- (instancetype)init {
    self = [super init];
    if (self) {
        self.inQueueSuppliers = [NSMutableArray array];
    }
    return self;
}
@end
