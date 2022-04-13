//
//  AdvTrackEventParameters.h
//  AdvanceSDK
//
//  Created by MS on 2021/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 统计事件
typedef enum : NSUInteger {
    AdvTrackEventCase_getInfo,
    AdvTrackEventCase_getAction,
} AdvTrackEventCase;

@interface AdvTrackEventParameters : NSObject
- (void)advTrackEventParametersActionWithCase:(AdvTrackEventCase)eventCase;


@end

NS_ASSUME_NONNULL_END
