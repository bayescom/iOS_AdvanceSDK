#import "AdvMaterialVideoFrameResolver.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>

static const NSUInteger kAdvMaterialMaxVideoLayers = 4;

@interface AdvMaterialVideoFrameCandidate : NSObject

@property (nonatomic, strong, nullable) AVAsset *asset;
@property (nonatomic, assign) CMTime time;
@property (nonatomic, assign) CGRect drawRect;
@property (nonatomic, assign) CGRect clipRect;
@property (nonatomic, copy) AVLayerVideoGravity gravity;
@property (nonatomic, strong, nullable) UIImage *frameImage;

@end

@implementation AdvMaterialVideoFrameCandidate
@end

@interface AdvMaterialVideoFrameResolver ()

@property (nonatomic, copy) NSArray<AdvMaterialVideoFrameCandidate *> *candidates;
@property (nonatomic, assign, readwrite) BOOL hasVisibleVideoLayer;

@end

@implementation AdvMaterialVideoFrameResolver

+ (nullable instancetype)resolverForImage:(UIImage *)image
                                 inWindow:(UIWindow *)window
                               screenRect:(CGRect)screenRect {
    NSAssert(NSThread.isMainThread, @"视频层信息必须在主线程读取");
    UIScreen *screen = window.screen ?: UIScreen.mainScreen;
    CGRect screenBounds = screen.bounds;
    CGRect captureRect = CGRectIsNull(screenRect) ? screenBounds : CGRectIntersection(screenBounds, CGRectStandardize(screenRect));
    if (!image.CGImage || CGRectIsNull(captureRect) || CGRectIsEmpty(captureRect)) {
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

    NSMutableArray<AdvMaterialVideoFrameCandidate *> *candidates = [NSMutableArray array];
    BOOL hasVisibleVideoLayer = NO;
    for (UIWindow *candidateWindow in windows) {
        if (candidateWindow.hidden || candidateWindow.alpha <= 0.01 || candidateWindow.screen != screen) {
            continue;
        }
        [self collectVideoLayersInLayer:candidateWindow.layer
                               inWindow:candidateWindow
                            captureRect:captureRect
                               clipRect:screenBounds
                              baseImage:image
                             candidates:candidates
                   hasVisibleVideoLayer:&hasVisibleVideoLayer];
        if (candidates.count >= kAdvMaterialMaxVideoLayers) {
            break;
        }
    }
    if (!hasVisibleVideoLayer) {
        return nil;
    }
    AdvMaterialVideoFrameResolver *resolver = [self new];
    resolver.candidates = candidates.copy;
    resolver.hasVisibleVideoLayer = YES;
    return resolver;
}

+ (void)collectVideoLayersInLayer:(CALayer *)layer
                         inWindow:(UIWindow *)window
                      captureRect:(CGRect)captureRect
                         clipRect:(CGRect)clipRect
                        baseImage:(UIImage *)baseImage
                       candidates:(NSMutableArray<AdvMaterialVideoFrameCandidate *> *)candidates
             hasVisibleVideoLayer:(BOOL *)hasVisibleVideoLayer {
    if (layer.hidden || layer.opacity <= 0.01 || candidates.count >= kAdvMaterialMaxVideoLayers) {
        return;
    }
    CGRect layerRect = CGRectNull;
    if (layer.masksToBounds || [layer isKindOfClass:AVPlayerLayer.class]) {
        CGRect windowRect = [layer convertRect:layer.bounds toLayer:window.layer];
        layerRect = [window convertRect:windowRect toWindow:nil];
    }
    if (layer.masksToBounds) {
        clipRect = CGRectIntersection(clipRect, layerRect);
        if (CGRectIsNull(clipRect) || CGRectIsEmpty(clipRect)) {
            return;
        }
    }
    if ([layer isKindOfClass:AVPlayerLayer.class]) {
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)layer;
        CGRect visibleRect = CGRectIntersection(CGRectIntersection(layerRect, clipRect), captureRect);
        if (!CGRectIsNull(visibleRect) && !CGRectIsEmpty(visibleRect)) {
            AVPlayerItem *currentItem = playerLayer.player.currentItem;
            if (currentItem && currentItem.status != AVPlayerItemStatusFailed) {
                *hasVisibleVideoLayer = YES;
            }
            CGRect videoRect = playerLayer.videoRect;
            if (CGRectIsNull(videoRect) || CGRectIsEmpty(videoRect)) {
                videoRect = playerLayer.bounds;
            }
            videoRect = CGRectIntersection(videoRect, playerLayer.bounds);
            CGRect videoWindowRect = [playerLayer convertRect:videoRect toLayer:window.layer];
            CGRect videoScreenRect = [window convertRect:videoWindowRect toWindow:nil];
            CGRect sampleRect = CGRectIntersection(CGRectIntersection(videoScreenRect, clipRect), captureRect);
            sampleRect = CGRectOffset(sampleRect, -captureRect.origin.x, -captureRect.origin.y);
            if (!CGRectIsNull(sampleRect) && !CGRectIsEmpty(sampleRect) &&
                [self isMostlyBlackImage:baseImage inRect:sampleRect]) {
                AdvMaterialVideoFrameCandidate *candidate = [AdvMaterialVideoFrameCandidate new];
                candidate.drawRect = CGRectOffset(layerRect, -captureRect.origin.x, -captureRect.origin.y);
                candidate.clipRect = CGRectOffset(visibleRect, -captureRect.origin.x, -captureRect.origin.y);
                candidate.gravity = playerLayer.videoGravity ?: AVLayerVideoGravityResizeAspect;
                UIImage *layerImage = [self renderedImageForPlayerLayer:playerLayer];
                CGRect layerSampleRect = CGRectOffset(videoRect, -playerLayer.bounds.origin.x, -playerLayer.bounds.origin.y);
                if (layerImage && ![self isMostlyBlackImage:layerImage inRect:layerSampleRect]) {
                    candidate.frameImage = layerImage;
                } else {
                    AVPlayer *player = playerLayer.player;
                    AVPlayerItem *item = currentItem;
                    CMTime time = player.currentTime;
                    if (item.status == AVPlayerItemStatusReadyToPlay && item.asset &&
                        CMTIME_IS_NUMERIC(time) && CMTimeCompare(time, kCMTimeZero) >= 0) {
                        candidate.asset = item.asset;
                        candidate.time = time;
                    }
                }
                if (candidate.frameImage || candidate.asset) {
                    [candidates addObject:candidate];
                }
            }
        }
    }
    for (CALayer *sublayer in layer.sublayers) {
        [self collectVideoLayersInLayer:sublayer
                              inWindow:window
                           captureRect:captureRect
                              clipRect:clipRect
                             baseImage:baseImage
                            candidates:candidates
                  hasVisibleVideoLayer:hasVisibleVideoLayer];
        if (candidates.count >= kAdvMaterialMaxVideoLayers) {
            break;
        }
    }
}

+ (nullable UIImage *)renderedImageForPlayerLayer:(AVPlayerLayer *)layer {
    CGRect bounds = layer.bounds;
    CGFloat longSide = MAX(CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    if (longSide <= 1) {
        return nil;
    }
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    format.opaque = YES;
    format.scale = MIN(1.0, 720.0 / longSide);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:bounds.size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [[UIColor blackColor] setFill];
        UIRectFill((CGRect){CGPointZero, bounds.size});
        CGContextTranslateCTM(context.CGContext, -bounds.origin.x, -bounds.origin.y);
        [layer renderInContext:context.CGContext];
    }];
}

+ (BOOL)isMostlyBlackImage:(UIImage *)image inRect:(CGRect)rect {
    CGRect imageBounds = CGRectMake(0, 0, image.size.width, image.size.height);
    CGRect sampleRect = CGRectIntersection(imageBounds, CGRectStandardize(rect));
    if (!image.CGImage || CGRectIsNull(sampleRect) || CGRectGetWidth(sampleRect) < 2 || CGRectGetHeight(sampleRect) < 2) {
        return NO;
    }
    CGFloat scaleX = (CGFloat)CGImageGetWidth(image.CGImage) / image.size.width;
    CGFloat scaleY = (CGFloat)CGImageGetHeight(image.CGImage) / image.size.height;
    CGRect pixelRect = CGRectMake(sampleRect.origin.x * scaleX, sampleRect.origin.y * scaleY,
                                  sampleRect.size.width * scaleX, sampleRect.size.height * scaleY);
    CGRect pixelBounds = CGRectMake(0, 0, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
    pixelRect = CGRectIntersection(CGRectIntegral(pixelRect), pixelBounds);
    CGImageRef croppedImage = CGImageCreateWithImageInRect(image.CGImage, pixelRect);
    if (!croppedImage) {
        return NO;
    }
    const size_t side = 24;
    uint8_t pixels[24 * 24 * 4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, side, side, 8, side * 4, colorSpace,
                                                 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        CGImageRelease(croppedImage);
        return NO;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, side, side), croppedImage);
    CGContextRelease(context);
    CGImageRelease(croppedImage);
    NSUInteger blackPixels = 0;
    for (NSUInteger index = 0; index < side * side; index++) {
        const uint8_t *pixel = pixels + index * 4;
        if (pixel[0] <= 20 && pixel[1] <= 20 && pixel[2] <= 20) {
            blackPixels += 1;
        }
    }
    return blackPixels >= side * side * 3 / 4;
}

- (UIImage *)imageByCompositingOnImage:(UIImage *)image {
    BOOL hasFrame = NO;
    for (AdvMaterialVideoFrameCandidate *candidate in self.candidates) {
        if (!candidate.frameImage && candidate.asset) {
            candidate.frameImage = [self generatedImageForCandidate:candidate imageScale:image.scale];
        }
        hasFrame = hasFrame || candidate.frameImage != nil;
    }
    if (!hasFrame) {
        return image;
    }
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    format.opaque = YES;
    format.scale = image.scale;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:image.size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [image drawInRect:(CGRect){CGPointZero, image.size}];
        for (AdvMaterialVideoFrameCandidate *candidate in self.candidates) {
            UIImage *frameImage = candidate.frameImage;
            if (!frameImage) {
                continue;
            }
            CGRect drawRect = [self drawRectForImage:frameImage inCandidate:candidate];
            CGContextSaveGState(context.CGContext);
            CGContextClipToRect(context.CGContext, candidate.clipRect);
            [frameImage drawInRect:drawRect];
            CGContextRestoreGState(context.CGContext);
        }
    }];
}

- (nullable UIImage *)generatedImageForCandidate:(AdvMaterialVideoFrameCandidate *)candidate
                                       imageScale:(CGFloat)imageScale {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:candidate.asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimePositiveInfinity;
    generator.requestedTimeToleranceAfter = kCMTimePositiveInfinity;
    CGFloat longSide = MAX(CGRectGetWidth(candidate.drawRect), CGRectGetHeight(candidate.drawRect));
    CGFloat maximumSide = MIN(1280.0, longSide * MAX(1.0, imageScale));
    if (maximumSide > 1 && longSide > 1) {
        CGFloat ratio = maximumSide / longSide;
        generator.maximumSize = CGSizeMake(CGRectGetWidth(candidate.drawRect) * ratio,
                                            CGRectGetHeight(candidate.drawRect) * ratio);
    }
    CGImageRef frame = [generator copyCGImageAtTime:candidate.time actualTime:NULL error:NULL];
    if (!frame) {
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage:frame];
    CGImageRelease(frame);
    return image;
}

- (CGRect)drawRectForImage:(UIImage *)image inCandidate:(AdvMaterialVideoFrameCandidate *)candidate {
    CGRect bounds = candidate.drawRect;
    if ([candidate.gravity isEqualToString:AVLayerVideoGravityResize] ||
        image.size.width <= 0 || image.size.height <= 0) {
        return bounds;
    }
    CGFloat widthRatio = CGRectGetWidth(bounds) / image.size.width;
    CGFloat heightRatio = CGRectGetHeight(bounds) / image.size.height;
    CGFloat ratio = [candidate.gravity isEqualToString:AVLayerVideoGravityResizeAspectFill] ?
        MAX(widthRatio, heightRatio) : MIN(widthRatio, heightRatio);
    CGSize size = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    return CGRectMake(CGRectGetMidX(bounds) - size.width / 2,
                      CGRectGetMidY(bounds) - size.height / 2,
                      size.width, size.height);
}

@end
