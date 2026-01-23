//
//  AdvanceRewardVideoCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"

@protocol AdvanceRewardVideoCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceRewardVideoCommonAdapter> delegate;

- (void)rewardAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)rewardAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)rewardAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId;

- (void)rewardAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)rewardAdapter_didAdClickedWithAdapterId:(NSString *)adapterId;

- (void)rewardAdapter_didAdClosedWithAdapterId:(NSString *)adapterId;

- (void)rewardAdapter_didAdVerifyRewardWithAdapterId:(NSString *)adapterId;// 验证激励回调

- (void)rewardAdapter_didAdPlayFinishWithAdapterId:(NSString *)adapterId;

@end

