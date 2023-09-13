//
//  AdvBayesSDKConfig.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvBayesSDKConfig : NSObject

/// 阿里提供给媒体的mediaId
@property (nonatomic, copy) NSString *aliMediaId;

/// 阿里提供给媒体的mediaSecret
@property (nonatomic, copy) NSString *aliMediaSecret;

@property (nonatomic, copy) NSString *userAgent;

+ (instancetype)sharedInstance;

/// set UserAgent for BayesSDK
+ (void)setUserAgent:(NSString *)ua;

/// set AAID for BayesSDK
/// - Parameters:
///   - mediaId: 阿里提供给媒体的mediaId
///   - mediaSecret: 阿里提供给媒体的mediaSecret
+ (void)setAAIDWithMediaId:(NSString *)mediaId
               mediaSecret:(NSString *)mediaSecret;


@end

NS_ASSUME_NONNULL_END
