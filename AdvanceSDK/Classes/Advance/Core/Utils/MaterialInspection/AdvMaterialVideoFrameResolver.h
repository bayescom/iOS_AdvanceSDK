#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvMaterialVideoFrameResolver : NSObject

/// 是否发现当前采集区域内可见的播放器，与截图是否需要补帧无关。
@property (nonatomic, assign, readonly) BOOL hasVisibleVideoLayer;

/// 在主线程记录当前可见播放器的信息；没有可见播放器时返回 nil。
+ (nullable instancetype)resolverForImage:(UIImage *)image
                                 inWindow:(UIWindow *)window
                               screenRect:(CGRect)screenRect;

/// 在后台从播放器素材取帧，并合成到原截图；取帧失败时保留原截图。
- (UIImage *)imageByCompositingOnImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
