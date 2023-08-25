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

@end

