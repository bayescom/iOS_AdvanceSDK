//
//  KSCUHorizontalFeed.h
//  AFNetworking
//
//  Created by jie cai on 2020/12/18.
//

#import <Foundation/Foundation.h>
#import "KSCUContentPageDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KSCUHorizontalFeedCallBackProtocol <KSCUVideoStateDelegate>

@end

@interface KSCUHorizontalFeedConfig : NSObject

///跳转是否隐藏 TarBar,默认为 YES
@property(nonatomic, assign) BOOL hidesBottomBarWhenPushed;

@property (nonatomic, weak, nullable) id<KSCUHorizontalFeedCallBackProtocol> callBackDelegate;

@end

@interface KSCUHorizontalFeed : NSObject

@property (nonatomic, strong,readonly) UIViewController *feedViewController;

- (instancetype)initWithPosId:(NSString *)posId
                configBuilder:(void(^ _Nullable)(KSCUHorizontalFeedConfig *config) )configBuilder NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
