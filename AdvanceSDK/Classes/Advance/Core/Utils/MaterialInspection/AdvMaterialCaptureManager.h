#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AdvMaterialCaptureStatus) {
    AdvMaterialCaptureStatusUploaded,
    AdvMaterialCaptureStatusDuplicate,
    AdvMaterialCaptureStatusSamplingSkipped,
    AdvMaterialCaptureStatusUploadFailed,
    AdvMaterialCaptureStatusDisabled,
    AdvMaterialCaptureStatusInvalidConfiguration,
    AdvMaterialCaptureStatusInvalidInput,
    AdvMaterialCaptureStatusAlreadyStarted,
    AdvMaterialCaptureStatusCaptureStopped,
    AdvMaterialCaptureStatusApplicationInactive,
    AdvMaterialCaptureStatusViewUnavailable,
    AdvMaterialCaptureStatusCaptureFailed,
    AdvMaterialCaptureStatusImageProcessingFailed
};

@interface AdvMaterialCaptureResult : NSObject

/// 采样与上传的最终状态。
@property (nonatomic, assign, readonly) AdvMaterialCaptureStatus status;
/// 未开始截帧时可能为空。
@property (nonatomic, copy, readonly, nullable) NSString *sampleId;
/// 未上传成功时为空数组。
@property (nonatomic, copy, readonly) NSArray<NSString *> *urls;
/// 未上传时的原因说明；上传成功时为空。
@property (nonatomic, copy, readonly, nullable) NSString *reason;

@end

typedef void (^AdvMaterialCaptureCompletion)(AdvMaterialCaptureResult *result);

@interface AdvMaterialCaptureManager : NSObject

/// 在广告曝光后调用；传入窗口采集整屏，传入普通视图则在截帧时计算其可见区域。
/// 采样、取图、去重和上传的最终状态均在主线程回调。
- (void)startCaptureIfNeededInView:(nullable UIView *)view
                       adnSourceId:(NSString *)adnSourceId
                        completion:(nullable AdvMaterialCaptureCompletion)completion;

/// 广告关闭时停止后续截帧；多帧模式按实际采到的帧数上传。
- (void)finishCapture;

@end

NS_ASSUME_NONNULL_END
