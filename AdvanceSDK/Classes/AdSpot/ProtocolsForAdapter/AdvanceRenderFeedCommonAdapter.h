//
//  AdvanceNativeExpressCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"

@protocol AdvanceRenderFeedCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> delegate;

- (void)renderAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)renderAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)renderAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId;

- (void)renderAdapter_didAdClickedWithAdapterId:(NSString *)adapterId;

- (void)renderAdapter_didAdClosedWithAdapterId:(NSString *)adapterId;

- (void)renderAdapter_didAdClosedDetailPageWithAdapterId:(NSString *)adapterId;

- (void)renderAdapter_didAdPlayFinishWithAdapterId:(NSString *)adapterId;

@end

