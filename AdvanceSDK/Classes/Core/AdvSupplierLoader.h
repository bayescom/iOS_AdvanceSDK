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

+ (void)loadSupplier:(AdvSupplier *)supplier completion:(void (^)(void))completion;

@end

