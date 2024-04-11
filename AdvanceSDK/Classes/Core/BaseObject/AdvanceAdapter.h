//
//  AdvanceAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/8/24.
//

#import <Foundation/Foundation.h>

@protocol AdvanceAdapter <NSObject>

@required
/// 命中该adapter后，执行回调逻辑
- (void)winnerAdapterToShowAd;

@optional
@property (nonatomic, assign) BOOL isWinnerAdapter;
@property (nonatomic, assign) BOOL isVideoCached;
- (void)renderNativeAdView;

@end

