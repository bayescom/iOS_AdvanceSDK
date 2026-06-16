//
//  AdvSigmobRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvSigmobRenderFeedAdDataSource.h"

@interface AdvSigmobRenderFeedAdDataSource ()
@property (nonatomic, strong) WindNativeAd *nativeAd;

@end

@implementation AdvSigmobRenderFeedAdDataSource

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd {
    self = [super init];
    if (self) {
        _nativeAd = nativeAd;
    }
    return self;
}

- (NSString *)title {
    return _nativeAd.title;
}

- (NSString *)desc {
    return _nativeAd.desc;
}

- (NSString *)iconUrl {
    return _nativeAd.iconUrl;
}

- (NSArray *)imageUrlList {
    return _nativeAd.imageUrlList;
}

- (NSInteger)mediaWidth {
    if ([self isVideoAd]) {
        return _nativeAd.videoWidth;
    }
    return [[self splitImageSizeString:_nativeAd.imageSizeList.firstObject].firstObject integerValue];
}

- (NSInteger)mediaHeight {
    if ([self isVideoAd]) {
        return _nativeAd.videoHeight;
    }
    return [[self splitImageSizeString:_nativeAd.imageSizeList.firstObject].lastObject integerValue];
}

- (NSString *)buttonText {
    return _nativeAd.callToAction;
}

- (BOOL)isVideoAd {
    switch (_nativeAd.feedADMode) {
        case WindFeedADModeVideo:
        case WindFeedADModeVideoPortrait:
        case WindFeedADModeVideoLandSpace:
            return YES;
        default:
            return NO;
    }
}

- (NSInteger)appRating {
    return _nativeAd.rating;
}

/// 解析字符串 " {100, 200} "
- (NSArray *)splitImageSizeString:(NSString *)sizeString {
    // 去掉大括号
    NSString *cleanedString = [sizeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    // 使用逗号分隔字符串
    NSArray *components = [cleanedString componentsSeparatedByString:@","];
    // 转换为数字
    if (components.count == 2) {
        NSString *firstString = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *secondString = [components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return @[firstString, secondString];
    }
    return @[];
}

@end
