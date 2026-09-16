#import <Foundation/Foundation.h>
#import "AdvAdapterDescriptor.h"

@class AdvCustomAdnModel;

NS_ASSUME_NONNULL_BEGIN

// SDK 内部渠道表，由启动流程维护，不需要宿主注册。
@interface AdvAdapterRepository : NSObject

+ (instancetype)sharedInstance;

- (void)loadBuiltInAdapterDescriptors;
- (void)syncCustomAdaptersWithAdnList:(nullable NSArray<AdvCustomAdnModel *> *)adnList;
- (nullable AdvAdapterDescriptor *)descriptorForSupplierId:(NSString *)supplierId;
- (NSArray<AdvAdapterDescriptor *> *)allDescriptors;

@end

NS_ASSUME_NONNULL_END
