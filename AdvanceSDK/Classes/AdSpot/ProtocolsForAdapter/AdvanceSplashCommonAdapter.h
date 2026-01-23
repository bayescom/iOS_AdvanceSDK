//
//  AdvanceSplashCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"

@protocol AdvanceSplashCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceSplashCommonAdapter> delegate;

- (void)splashAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)splashAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)splashAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId;

- (void)splashAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)splashAdapter_didAdClickedWithAdapterId:(NSString *)adapterId;

- (void)splashAdapter_didAdClosedWithAdapterId:(NSString *)adapterId;

@end

