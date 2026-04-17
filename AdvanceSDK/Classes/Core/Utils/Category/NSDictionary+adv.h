//
//  NSDictionary+adv.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (adv)

- (NSString *)toErrorDescriptionString;

- (NSString *)toErrorJSONString;

- (NSString *)toErrorLogString;

@end

NS_ASSUME_NONNULL_END
