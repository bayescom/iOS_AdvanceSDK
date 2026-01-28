//
//  AdvanceNativeExpressCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"
#import "AdvNativeExpressAdWrapper.h"

@protocol AdvanceNativeExpressCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceNativeExpressCommonAdapter> delegate;

- (void)nativeAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)nativeAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)nativeAdapter_didAdRenderSuccessWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper;

- (void)nativeAdapter_didAdRenderFailWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper error:(NSError *)error;

- (void)nativeAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper;

- (void)nativeAdapter_didAdClickedWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper;

- (void)nativeAdapter_didAdClosedWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper;

@end

