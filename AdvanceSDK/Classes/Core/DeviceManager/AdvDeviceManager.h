#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvDeviceManager : NSObject

@property (nonatomic, assign) BOOL isAdTrack;
@property (nonatomic, copy) NSString *appId;

+ (instancetype)sharedInstance;

/// 广告请求时，获取设备参数信息
- (NSDictionary *)getDeviceInfoForAdRequest;

+ (NSString *)getUUID;

@end

NS_ASSUME_NONNULL_END
