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

+ (BOOL)isSDKInstalledWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingSplashAdapterClassNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingInterstitialAdapterClassNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingRewardAdapterClassNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingFullScreenAdapterClassNameWithSupplierId:(NSString *)supplierId;

@end

