//
//  AdvanceBaseDelegate.h
//  AdvanceSDK
//
//  Created by allen on 2020/4/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceBaseDelegate <NSObject>
@optional
//广告填充失败未出广告
- (void)advanceOnAdNotFilled:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
