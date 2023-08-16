//
//  AdvSupplierLoader.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyModel.h"

//MARK: 渠道SDK初始化器
@interface AdvSupplierLoader : NSObject

+ (instancetype)defaultInstance;

- (void)loadSupplier:(AdvSupplier *)supplier extra:(NSDictionary *)extra;

@end

