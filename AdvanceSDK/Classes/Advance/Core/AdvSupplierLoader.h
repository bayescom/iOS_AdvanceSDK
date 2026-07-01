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

+ (void)loadSupplier:(AdvSupplier *)supplier completion:(void (^)(NSError *error))completion;

+ (NSString *)mappingConfigAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingSplashAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingInterstitialAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingRewardAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingFullScreenAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingNativeExpressAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingRenderFeedAdapterNameWithSupplierId:(NSString *)supplierId;

+ (NSString *)mappingBannerAdapterNameWithSupplierId:(NSString *)supplierId;

@end

