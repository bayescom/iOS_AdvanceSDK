//
//  AdvanceBannerCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"

@protocol AdvanceBannerCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceBannerCommonAdapter> delegate;

- (void)bannerAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)bannerAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)bannerAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId;

- (void)bannerAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)bannerAdapter_didAdClickedWithAdapterId:(NSString *)adapterId;

- (void)bannerAdapter_didAdClosedWithAdapterId:(NSString *)adapterId;

@end

