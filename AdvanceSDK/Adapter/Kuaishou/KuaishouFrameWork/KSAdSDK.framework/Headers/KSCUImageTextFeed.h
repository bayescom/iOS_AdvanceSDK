//
//  KSCUImageTextFeed.h
//  KSAdSDK
//
//  Created by jie cai on 2021/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSCUImageTextFeed : NSObject

@property (nonatomic, readonly) UIViewController *feedViewController;

- (instancetype)initWithPosId:(NSString *)posId NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
