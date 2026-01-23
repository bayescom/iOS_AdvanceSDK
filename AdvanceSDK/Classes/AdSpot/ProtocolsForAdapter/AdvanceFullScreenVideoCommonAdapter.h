//
//  AdvanceFullScreenVideoCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"

@protocol AdvanceFullScreenVideoCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceFullScreenVideoCommonAdapter> delegate;

- (void)fullscreenAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)fullscreenAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)fullscreenAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId;

- (void)fullscreenAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)fullscreenAdapter_didAdClickedWithAdapterId:(NSString *)adapterId;

- (void)fullscreenAdapter_didAdClosedWithAdapterId:(NSString *)adapterId;

- (void)fullscreenAdapter_didAdPlayFinishWithAdapterId:(NSString *)adapterId;

@end

