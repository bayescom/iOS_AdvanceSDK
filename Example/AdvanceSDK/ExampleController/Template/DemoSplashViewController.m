//
//  DemoSplashViewController.m
//  AAA
//
//  Created by CherryKing on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoSplashViewController.h"

#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSplash.h>

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10002619"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                  viewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    self.advanceSplash.delegate = self;
    self.advanceSplash.showLogoRequire = YES;
    self.advanceSplash.logoImage = [self mer_imageWithOriginalImage:[UIImage imageNamed:@"app_logo2"] scaleSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.16)];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotId:@"10002436"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkId:SDK_ID_MERCURY];
    [self.advanceSplash loadAd];
}

// 此方法用于按照指定尺寸重绘Logo
- (UIImage *)mer_imageWithOriginalImage:(UIImage *)originalImage scaleSize:(CGSize)size {
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextAddPath(context, outerPath.CGPath);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextDrawPath(context, kCGPathFill);
        CGContextStrokePath(context);
        BOOL isWidthFit = size.width/originalImage.size.width > size.height/originalImage.size.height;
        if (!isWidthFit) {
            CGFloat targetH = originalImage.size.height*size.width/originalImage.size.width;
            CGContextDrawImage(context, CGRectMake(0, (size.height - targetH)/2.0, size.width, targetH), originalImage.CGImage);
        } else {
            CGFloat targetW = originalImage.size.width*size.height/originalImage.size.height;
            CGContextDrawImage(context, CGRectMake((size.width - targetW)/2.0, 0, targetW, size.height), originalImage.CGImage);
        }
    }CGContextRestoreGState(context);
    UIImage *radiusImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return radiusImage;
}

// MARK: ======================= AdvanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived {
//    NSLog(@"广告数据拉取成功"];
    NSLog(@"广告数据拉取成功");
}

/// 广告曝光成功
- (void)advanceSplashOnAdShow {
    NSLog(@"广告曝光成功");
}

/// 广告展示失败
- (void)advanceSplashOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告展示失败(%@):%@", sdkId, error);
}

/// 广告点击
- (void)advanceSplashOnAdClicked {
    NSLog(@"广告点击");
}

/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked {
    NSLog(@"广告点击跳过");
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
    NSLog(@"广告倒计时结束");
}

@end
