#import "AdvMaterialCaptureManager.h"
#import "AdvMaterialVideoFrameResolver.h"
#import "AdvApiService.h"
#import "AdvConfigCacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import <stdlib.h>

static const NSUInteger kAdvMaterialMaxFingerprints = 256;
static const NSTimeInterval kAdvMaterialFingerprintLifetime = 24 * 60 * 60;

@interface AdvMaterialFrame : NSObject

@property (nonatomic, assign) NSUInteger frameIndex;
@property (nonatomic, strong) NSDate *capturedAt;
@property (nonatomic, copy) NSData *jpegData;

@end

@implementation AdvMaterialFrame
@end

@interface AdvMaterialCaptureResult ()

@property (nonatomic, assign, readwrite) AdvMaterialCaptureStatus status;
@property (nonatomic, copy, readwrite, nullable) NSString *sampleId;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *urls;

@end

@implementation AdvMaterialCaptureResult

- (NSString * _Nullable)reason {
    switch (self.status) {
        case AdvMaterialCaptureStatusUploaded: return nil;
        case AdvMaterialCaptureStatusDuplicate: return @"重复素材";
        case AdvMaterialCaptureStatusSamplingSkipped: return @"未命中采样率";
        case AdvMaterialCaptureStatusUploadFailed: return @"图片上传失败";
        case AdvMaterialCaptureStatusDisabled: return @"素材巡检配置未开启";
        case AdvMaterialCaptureStatusInvalidConfiguration: return @"素材巡检配置无效";
        case AdvMaterialCaptureStatusInvalidInput: return @"采样视图或广告源 ID 无效";
        case AdvMaterialCaptureStatusAlreadyStarted: return @"采样任务已开始或结束";
        case AdvMaterialCaptureStatusCaptureStopped: return @"首次截帧前广告已结束";
        case AdvMaterialCaptureStatusApplicationInactive: return @"采样时应用不在前台";
        case AdvMaterialCaptureStatusViewUnavailable: return @"采样视图已离屏、隐藏或不可见";
        case AdvMaterialCaptureStatusCaptureFailed: return @"截图失败";
        case AdvMaterialCaptureStatusImageProcessingFailed: return @"图片压缩失败";
    }
    return @"未知采样状态";
}

@end

@interface AdvMaterialRawFrame : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, nullable) AdvMaterialVideoFrameResolver *videoFrameResolver;
@property (nonatomic, assign) NSUInteger frameIndex;
@property (nonatomic, strong) NSDate *capturedAt;

@end

@implementation AdvMaterialRawFrame
@end

@interface AdvMaterialSignature : NSObject

@property (nonatomic, copy) NSString *sha256;
@property (nonatomic, assign) uint64_t differenceHash;
@property (nonatomic, assign) uint8_t averageLuma;
@property (nonatomic, assign) uint32_t averageColor;

@end

@implementation AdvMaterialSignature
@end

@interface AdvMaterialFingerprint : NSObject

@property (nonatomic, copy) NSString *adnSourceId;
@property (nonatomic, copy) NSArray<AdvMaterialSignature *> *signatures;
@property (nonatomic, strong) NSDate *capturedAt;

@end

@implementation AdvMaterialFingerprint
@end

@interface AdvMaterialCaptureManager ()

@property (nonatomic, weak) UIView *captureView;
@property (nonatomic, copy) NSString *sampleId;
@property (nonatomic, copy) NSString *adnSourceId;
@property (nonatomic, copy, nullable) AdvMaterialCaptureCompletion completion;
@property (nonatomic, assign) NSUInteger scheduledFrameCount;
@property (nonatomic, assign) dispatch_time_t captureStartTime;
@property (nonatomic, assign) NSTimeInterval captureDelaySeconds;
@property (nonatomic, assign) NSUInteger maxImageBytes;
@property (nonatomic, strong) NSMutableArray<AdvMaterialRawFrame *> *rawFrames;
@property (nonatomic, assign) NSUInteger generation;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL finished;

@end

@implementation AdvMaterialCaptureManager

static NSMutableArray<AdvMaterialFingerprint *> *sRecentFingerprints;

+ (void)removeFingerprint:(AdvMaterialFingerprint *)fingerprint {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFingerprint:fingerprint];
        });
        return;
    }
    [sRecentFingerprints removeObjectIdenticalTo:fingerprint];
}

+ (void)complete:(AdvMaterialCaptureCompletion _Nullable)completion
          status:(AdvMaterialCaptureStatus)status
        sampleId:(NSString * _Nullable)sampleId
            urls:(NSArray<NSString *> * _Nullable)urls {
    if (!completion) {
        return;
    }
    AdvMaterialCaptureResult *result = [AdvMaterialCaptureResult new];
    result.status = status;
    result.sampleId = sampleId;
    result.urls = urls ?: @[];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(result);
    });
}

+ (void)uploadFrames:(NSArray<AdvMaterialFrame *> *)frames
            sampleId:(NSString *)sampleId
         fingerprint:(AdvMaterialFingerprint *)fingerprint
          completion:(AdvMaterialCaptureCompletion _Nullable)completion {
    NSMutableArray<AdvNetworkImageFile *> *imageFiles = [NSMutableArray arrayWithCapacity:frames.count];
    for (AdvMaterialFrame *frame in frames) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%lu.jpg", sampleId, (unsigned long)frame.frameIndex];
        [imageFiles addObject:[[AdvNetworkImageFile alloc] initWithData:frame.jpegData fileName:fileName]];
    }
    if (imageFiles.count == 0) {
        [self removeFingerprint:fingerprint];
        [self complete:completion status:AdvMaterialCaptureStatusImageProcessingFailed sampleId:sampleId urls:nil];
        return;
    }
    
    NSUInteger expectedCount = imageFiles.count;
    [AdvApiService uploadImageFiles:imageFiles.copy completion:^(AdvImageUploadResult *uploadResult, NSError *error) {
        if (error || uploadResult.code != 200 || uploadResult.fail_count != 0 || uploadResult.urls.count != expectedCount) {
            // 本次未全部上传成功，释放去重标记，允许后续曝光再次尝试。
            [self removeFingerprint:fingerprint];
            [self complete:completion status:AdvMaterialCaptureStatusUploadFailed sampleId:sampleId urls:nil];
            return;
        }
        [self complete:completion status:AdvMaterialCaptureStatusUploaded sampleId:sampleId urls:uploadResult.urls.copy];
    }];
}

- (void)startCaptureIfNeededInView:(UIView * _Nullable)view
                       adnSourceId:(NSString *)adnSourceId
                        completion:(AdvMaterialCaptureCompletion _Nullable)completion {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startCaptureIfNeededInView:view adnSourceId:adnSourceId completion:completion];
        });
        return;
    }
    if (self.active || self.finished) {
        [[self class] complete:completion status:AdvMaterialCaptureStatusAlreadyStarted sampleId:nil urls:nil];
        return;
    }
    if (!view || !adnSourceId.length) {
        self.finished = YES;
        [[self class] complete:completion status:AdvMaterialCaptureStatusInvalidInput sampleId:nil urls:nil];
        return;
    }
    
    AdvMaterialInspectionConfig *config = [[AdvConfigCacheManager sharedInstance] sdkConfig].material_inspection_config;
    double sampleRate = config.exposure_sample_rate;
    if (config.enable != 1) {
        self.finished = YES;
        [[self class] complete:completion status:AdvMaterialCaptureStatusDisabled sampleId:nil urls:nil];
        return;
    }
    if (!isfinite(sampleRate) || sampleRate < 0 || sampleRate > 1 || config.image_max_size <= 0) {
        self.finished = YES;
        [[self class] complete:completion status:AdvMaterialCaptureStatusInvalidConfiguration sampleId:nil urls:nil];
        return;
    }
//    sampleRate = 1;
    double randomValue = (double)arc4random() / ((double)UINT32_MAX + 1.0);
    if (randomValue >= sampleRate) {
        self.finished = YES;
        [[self class] complete:completion status:AdvMaterialCaptureStatusSamplingSkipped sampleId:nil urls:nil];
        return;
    }
    
    NSInteger delayMs = config.capture_delay_ms;
    self.captureDelaySeconds = delayMs >= 0 ? delayMs / 1000.0 : 1.0;
    self.maxImageBytes = (NSUInteger)config.image_max_size * 1024;
    
    self.generation += 1;
    self.active = YES;
    self.captureView = view;
    self.sampleId = NSUUID.UUID.UUIDString;
    self.adnSourceId = adnSourceId;
    self.completion = completion;
    self.scheduledFrameCount = 1;
    self.rawFrames = [NSMutableArray arrayWithCapacity:3];
    self.captureStartTime = dispatch_time(DISPATCH_TIME_NOW, 0);
    
    NSUInteger generation = self.generation;
    // 曝光后等待画面稳定，先截一帧，再判断是否需要追加视频帧。
    [self scheduleFrameAtIndex:0 afterExposure:self.captureDelaySeconds generation:generation];
}

- (void)scheduleFrameAtIndex:(NSUInteger)index
               afterExposure:(NSTimeInterval)elapsed
                  generation:(NSUInteger)generation {
    dispatch_time_t deadline = dispatch_time(self.captureStartTime, (int64_t)(elapsed * NSEC_PER_SEC));
    __weak typeof(self) weakSelf = self;
    dispatch_after(deadline, dispatch_get_main_queue(), ^{
        [weakSelf captureFrameAtIndex:index generation:generation];
    });
}

- (void)finishCapture {
    [self finishCaptureWithNoFrameStatus:AdvMaterialCaptureStatusCaptureStopped];
}

- (void)finishCaptureWithNoFrameStatus:(AdvMaterialCaptureStatus)noFrameStatus {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishCaptureWithNoFrameStatus:noFrameStatus];
        });
        return;
    }
    if (!self.active) {
        self.finished = YES;
        return;
    }
    self.active = NO;
    self.finished = YES;
    self.captureView = nil;
    AdvMaterialCaptureCompletion completion = self.completion;
    self.completion = nil;
    NSArray<AdvMaterialRawFrame *> *rawFrames = self.rawFrames.copy;
    self.rawFrames = nil;
    NSString *sampleId = self.sampleId;
    if (rawFrames.count == 0) {
        [[self class] complete:completion status:noFrameStatus sampleId:sampleId urls:nil];
        return;
    }
    
    NSUInteger generation = self.generation;
    NSString *adnSourceId = self.adnSourceId;
    NSUInteger maxImageBytes = self.maxImageBytes;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        @autoreleasepool {
            NSMutableArray<AdvMaterialFrame *> *frames = [NSMutableArray arrayWithCapacity:rawFrames.count];
            NSMutableArray<AdvMaterialSignature *> *signatures = [NSMutableArray arrayWithCapacity:rawFrames.count];
            for (AdvMaterialRawFrame *rawFrame in rawFrames) {
                @autoreleasepool {
                    UIImage *image = rawFrame.videoFrameResolver ?
                    [rawFrame.videoFrameResolver imageByCompositingOnImage:rawFrame.image] : rawFrame.image;
                    NSData *jpegData = [self compressedJPEGForImage:image maxBytes:maxImageBytes];
                    if (!jpegData) {
                        continue;
                    }
                    NSString *sha256 = [self sha256ForData:jpegData];
                    uint8_t averageLuma = 0;
                    uint64_t differenceHash = [self differenceHashForImage:image averageLuma:&averageLuma];
                    uint32_t averageColor = [self averageColorForImage:image];
                    
                    AdvMaterialFrame *frame = [AdvMaterialFrame new];
                    frame.frameIndex = rawFrame.frameIndex;
                    frame.capturedAt = rawFrame.capturedAt;
                    frame.jpegData = jpegData;
                    [frames addObject:frame];
                    
                    AdvMaterialSignature *signature = [AdvMaterialSignature new];
                    signature.sha256 = sha256;
                    signature.differenceHash = differenceHash;
                    signature.averageLuma = averageLuma;
                    signature.averageColor = averageColor;
                    [signatures addObject:signature];
                }
            }
            if (frames.count == 0) {
                [[self class] complete:completion status:AdvMaterialCaptureStatusImageProcessingFailed sampleId:sampleId urls:nil];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (generation != self.generation) {
                    return;
                }
                AdvMaterialFingerprint *fingerprint = nil;
                if ([self isDuplicateExposureWithAdnSourceId:adnSourceId
                                                  signatures:signatures
                                                  capturedAt:frames.firstObject.capturedAt
                                                 fingerprint:&fingerprint]) {
                    [[self class] complete:completion status:AdvMaterialCaptureStatusDuplicate sampleId:sampleId urls:nil];
                    return;
                }
                [[self class] uploadFrames:frames.copy
                                  sampleId:sampleId
                               fingerprint:fingerprint
                                completion:completion];
            });
        }
    });
}

- (CGRect)screenRectForCaptureView:(UIView *)view inWindow:(UIWindow *)window {
    if (window.hidden || window.alpha <= 0.01 || CGRectIsEmpty(view.bounds)) {
        return CGRectNull;
    }
    CGRect visibleRect = [view convertRect:view.bounds toView:window];
    for (UIView *ancestor = view; ancestor; ancestor = ancestor.superview) {
        if (ancestor.hidden || ancestor.alpha <= 0.01) {
            return CGRectNull;
        }
        if (ancestor != view && ancestor.clipsToBounds) {
            visibleRect = CGRectIntersection(visibleRect, [ancestor convertRect:ancestor.bounds toView:window]);
        }
        if (ancestor == window) {
            break;
        }
    }
    visibleRect = CGRectIntersection(visibleRect, window.bounds);
    if (CGRectIsNull(visibleRect) || CGRectIsEmpty(visibleRect)) {
        return CGRectNull;
    }
    return [window convertRect:visibleRect toWindow:nil];
}

- (void)captureFrameAtIndex:(NSUInteger)index generation:(NSUInteger)generation {
    if (!self.active || generation != self.generation) {
        return;
    }
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        [self finishCaptureWithNoFrameStatus:AdvMaterialCaptureStatusApplicationInactive];
        return;
    }
    UIView *captureView = self.captureView;
    BOOL capturesWindow = [captureView isKindOfClass:UIWindow.class];
    UIWindow *window = capturesWindow ? (UIWindow *)captureView : captureView.window;
    if (!window) {
        [self finishCaptureWithNoFrameStatus:AdvMaterialCaptureStatusViewUnavailable];
        return;
    }
    CGRect screenRect = capturesWindow ? CGRectNull : [self screenRectForCaptureView:captureView inWindow:window];
    if (!capturesWindow && (CGRectIsNull(screenRect) || CGRectIsEmpty(screenRect))) {
        [self finishCaptureWithNoFrameStatus:AdvMaterialCaptureStatusViewUnavailable];
        return;
    }
    UIImage *image = [self screenshotForWindow:window screenRect:screenRect];
    if (image) {
        AdvMaterialRawFrame *frame = [AdvMaterialRawFrame new];
        frame.image = image;
        frame.videoFrameResolver = [AdvMaterialVideoFrameResolver resolverForImage:image
                                                                          inWindow:window
                                                                        screenRect:screenRect];
        frame.frameIndex = index;
        frame.capturedAt = [NSDate date];
        [self.rawFrames addObject:frame];
        if (index == 0 && frame.videoFrameResolver.hasVisibleVideoLayer) {
            self.scheduledFrameCount = 3;
            [self scheduleFrameAtIndex:1 afterExposure:self.captureDelaySeconds + 2.0 generation:generation];
            [self scheduleFrameAtIndex:2 afterExposure:self.captureDelaySeconds + 4.0 generation:generation];
        }
    }
    if (index + 1 == self.scheduledFrameCount) {
        if (image) {
            [self finishCapture];
        } else {
            [self finishCaptureWithNoFrameStatus:AdvMaterialCaptureStatusCaptureFailed];
        }
    }
}

- (UIImage *)screenshotForWindow:(UIWindow *)window screenRect:(CGRect)screenRect {
    UIScreen *screen = window.screen ?: UIScreen.mainScreen;
    CGRect screenBounds = screen.bounds;
    CGRect captureRect = CGRectIsNull(screenRect) ? screenBounds : CGRectIntersection(screenBounds, CGRectStandardize(screenRect));
    if (CGRectIsNull(captureRect) || CGRectIsEmpty(captureRect)) {
        return nil;
    }
    NSArray<UIWindow *> *windows = nil;
    if (@available(iOS 13.0, *)) {
        windows = window.windowScene ? window.windowScene.windows : UIApplication.sharedApplication.windows;
    } else {
        windows = UIApplication.sharedApplication.windows;
    }
    windows = [windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *first, UIWindow *second) {
        if (first.windowLevel < second.windowLevel) return NSOrderedAscending;
        if (first.windowLevel > second.windowLevel) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    format.opaque = YES;
    format.scale = MIN(screen.scale, 1280.0 / MAX(CGRectGetWidth(captureRect), CGRectGetHeight(captureRect)));
    // 先绘制完整屏幕，再裁切广告区域，避免将窗口直接绘进小画布时出现未渲染的黑块。
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:screenBounds.size format:format];
    __block BOOL drewWindow = NO;
    UIImage *screenImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [[UIColor blackColor] setFill];
        UIRectFill((CGRect){CGPointZero, screenBounds.size});
        for (UIWindow *candidate in windows) {
            if (candidate.hidden || candidate.alpha <= 0.01 || candidate.screen != screen) {
                continue;
            }
            CGRect windowRect = [candidate convertRect:candidate.bounds toWindow:nil];
            if (!CGRectIntersectsRect(windowRect, captureRect)) {
                continue;
            }
            CGRect rect = CGRectOffset(windowRect, -screenBounds.origin.x, -screenBounds.origin.y);
            drewWindow = YES;
            if (![candidate drawViewHierarchyInRect:rect afterScreenUpdates:YES] &&
                ![candidate drawViewHierarchyInRect:rect afterScreenUpdates:NO]) {
                CGContextRef cgContext = context.CGContext;
                CGContextSaveGState(cgContext);
                CGContextTranslateCTM(cgContext, rect.origin.x, rect.origin.y);
                [candidate.layer renderInContext:cgContext];
                CGContextRestoreGState(cgContext);
            }
        }
    }];
    if (!drewWindow || !screenImage.CGImage) {
        return nil;
    }
    CGFloat pixelScaleX = (CGFloat)CGImageGetWidth(screenImage.CGImage) / CGRectGetWidth(screenBounds);
    CGFloat pixelScaleY = (CGFloat)CGImageGetHeight(screenImage.CGImage) / CGRectGetHeight(screenBounds);
    CGRect pixelRect = CGRectMake((captureRect.origin.x - screenBounds.origin.x) * pixelScaleX,
                                  (captureRect.origin.y - screenBounds.origin.y) * pixelScaleY,
                                  captureRect.size.width * pixelScaleX,
                                  captureRect.size.height * pixelScaleY);
    CGRect imageBounds = CGRectMake(0, 0, CGImageGetWidth(screenImage.CGImage), CGImageGetHeight(screenImage.CGImage));
    pixelRect = CGRectIntersection(CGRectIntegral(pixelRect), imageBounds);
    if (CGRectIsNull(pixelRect) || CGRectIsEmpty(pixelRect)) {
        return nil;
    }
    CGImageRef croppedImage = CGImageCreateWithImageInRect(screenImage.CGImage, pixelRect);
    if (!croppedImage) {
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:screenImage.scale orientation:UIImageOrientationUp];
    CGImageRelease(croppedImage);
    return image;
}

- (NSData *)compressedJPEGForImage:(UIImage *)image maxBytes:(NSUInteger)maxBytes {
    const CGFloat longSides[] = {1280, 960, 720, 560};
    const CGFloat qualities[] = {0.88, 0.78, 0.68};
    for (NSUInteger sizeIndex = 0; sizeIndex < 4; sizeIndex++) {
        UIImage *scaledImage = [self image:image withMaximumPixelSide:longSides[sizeIndex]];
        if (!scaledImage) {
            return nil;
        }
        for (NSUInteger qualityIndex = 0; qualityIndex < 3; qualityIndex++) {
            NSData *data = UIImageJPEGRepresentation(scaledImage, qualities[qualityIndex]);
            if (data.length > 0 && data.length <= maxBytes) {
                return data;
            }
        }
    }
    return nil;
}

- (UIImage *)image:(UIImage *)image withMaximumPixelSide:(CGFloat)maximumSide {
    CGImageRef source = image.CGImage;
    if (!source) {
        return nil;
    }
    size_t width = CGImageGetWidth(source);
    size_t height = CGImageGetHeight(source);
    CGFloat ratio = MIN(1.0, maximumSide / MAX(width, height));
    if (ratio >= 1.0) {
        return image;
    }
    size_t scaledWidth = MAX(1, (size_t)round(width * ratio));
    size_t scaledHeight = MAX(1, (size_t)round(height * ratio));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return nil;
    }
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, scaledWidth, scaledHeight), source);
    CGImageRef output = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    if (!output) {
        return nil;
    }
    UIImage *scaledImage = [UIImage imageWithCGImage:output];
    CGImageRelease(output);
    return scaledImage;
}

- (NSString *)sha256ForData:(NSData *)data {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (NSUInteger index = 0; index < CC_SHA256_DIGEST_LENGTH; index++) {
        [result appendFormat:@"%02x", digest[index]];
    }
    return result;
}

- (uint64_t)differenceHashForImage:(UIImage *)image averageLuma:(uint8_t *)averageLuma {
    unsigned char pixels[9 * 8] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pixels, 9, 8, 8, 9, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return 0;
    }
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, 9, 8), image.CGImage);
    CGContextRelease(context);
    uint64_t hash = 0;
    NSUInteger sum = 0;
    for (NSUInteger row = 0; row < 8; row++) {
        for (NSUInteger column = 0; column < 9; column++) {
            sum += pixels[row * 9 + column];
            if (column < 8) {
                hash = (hash << 1) | (pixels[row * 9 + column] > pixels[row * 9 + column + 1]);
            }
        }
    }
    *averageLuma = (uint8_t)(sum / (9 * 8));
    return hash;
}

- (uint32_t)averageColorForImage:(UIImage *)image {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return 0;
    }
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGContextRelease(context);
    return ((uint32_t)pixel[0] << 16) | ((uint32_t)pixel[1] << 8) | pixel[2];
}

- (BOOL)isSameImageSignature:(AdvMaterialSignature *)first other:(AdvMaterialSignature *)second {
    unsigned int changedBits = __builtin_popcountll(first.differenceHash ^ second.differenceHash);
    uint32_t firstColor = first.averageColor;
    uint32_t secondColor = second.averageColor;
    BOOL closeColor = abs((int)((firstColor >> 16) & 0xff) - (int)((secondColor >> 16) & 0xff)) <= 16 &&
    abs((int)((firstColor >> 8) & 0xff) - (int)((secondColor >> 8) & 0xff)) <= 16 &&
    abs((int)(firstColor & 0xff) - (int)(secondColor & 0xff)) <= 16;
    return [first.sha256 isEqualToString:second.sha256] ||
    (changedBits <= 3 && abs((int)first.averageLuma - (int)second.averageLuma) <= 12 && closeColor);
}

- (NSArray<AdvMaterialSignature *> *)representativeSignatures:(NSArray<AdvMaterialSignature *> *)signatures {
    NSMutableArray<AdvMaterialSignature *> *representatives = [NSMutableArray array];
    for (AdvMaterialSignature *signature in signatures) {
        BOOL alreadyRepresented = NO;
        for (AdvMaterialSignature *representative in representatives) {
            if ([self isSameImageSignature:signature other:representative]) {
                alreadyRepresented = YES;
                break;
            }
        }
        if (!alreadyRepresented) {
            [representatives addObject:signature];
        }
    }
    return representatives.copy;
}

- (BOOL)isDuplicateExposureWithAdnSourceId:(NSString *)adnSourceId
                                signatures:(NSArray<AdvMaterialSignature *> *)signatures
                                capturedAt:(NSDate *)capturedAt
                               fingerprint:(AdvMaterialFingerprint * _Nullable * _Nullable)registeredFingerprint {
    if (!sRecentFingerprints) {
        sRecentFingerprints = [NSMutableArray array];
    }
    NSIndexSet *expired = [sRecentFingerprints indexesOfObjectsPassingTest:^BOOL(AdvMaterialFingerprint *fingerprint, NSUInteger index, BOOL *stop) {
        return [capturedAt timeIntervalSinceDate:fingerprint.capturedAt] > kAdvMaterialFingerprintLifetime;
    }];
    [sRecentFingerprints removeObjectsAtIndexes:expired];
    NSArray<AdvMaterialSignature *> *representatives = [self representativeSignatures:signatures];
    for (AdvMaterialFingerprint *fingerprint in sRecentFingerprints) {
        if (![fingerprint.adnSourceId isEqualToString:adnSourceId]) {
            continue;
        }
        if ((representatives.count == 1) != (fingerprint.signatures.count == 1)) {
            continue;
        }
        // 多帧动态素材至少匹配两幅不同画面；静态素材只需匹配一幅。
        NSUInteger requiredMatches = MIN(2, MIN(representatives.count, fingerprint.signatures.count));
        if (requiredMatches == 0) {
            continue;
        }
        NSMutableIndexSet *matchedOldFrames = [NSMutableIndexSet indexSet];
        for (AdvMaterialSignature *current in representatives) {
            for (NSUInteger index = 0; index < fingerprint.signatures.count; index++) {
                if ([matchedOldFrames containsIndex:index]) {
                    continue;
                }
                if ([self isSameImageSignature:current other:fingerprint.signatures[index]]) {
                    [matchedOldFrames addIndex:index];
                    break;
                }
            }
        }
        if (matchedOldFrames.count >= requiredMatches) {
            return YES;
        }
    }
    AdvMaterialFingerprint *fingerprint = [AdvMaterialFingerprint new];
    fingerprint.adnSourceId = adnSourceId;
    fingerprint.signatures = representatives;
    fingerprint.capturedAt = capturedAt;
    [sRecentFingerprints addObject:fingerprint];
    if (registeredFingerprint) {
        *registeredFingerprint = fingerprint;
    }
    if (sRecentFingerprints.count > kAdvMaterialMaxFingerprints) {
        [sRecentFingerprints removeObjectAtIndex:0];
    }
    return NO;
}

@end
