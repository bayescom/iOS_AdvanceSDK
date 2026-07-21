//
//  AdvNoahRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahRenderFeedAdDataSource.h"

@interface AdvNoahRenderFeedAdDataSource ()
@property (nonatomic, strong) NAAdAssets *adAssets;

@end

@implementation AdvNoahRenderFeedAdDataSource

- (instancetype)initWithAdAssets:(NAAdAssets *)adAssets {
    self = [super init];
    if (self) {
        _adAssets = adAssets;
    }
    return self;
}

- (NSString *)title {
    return _adAssets.adTitle;
}

- (NSString *)desc {
    return _adAssets.adDescription;
}

- (NSString *)iconUrl {
    return _adAssets.adIcon.getUrl;
}

- (NSArray *)imageUrlList {
    NSMutableArray *urlList = [NSMutableArray array];
    for (Image * img in _adAssets.adImgs) {
        [urlList addObject:img.getUrl];
    }
    return [urlList copy];
}

- (NSInteger)mediaWidth {
    if ([self isVideoAd] && !_adAssets.adImgs.count) {
        return 720;
    }
    return _adAssets.adImgs.firstObject.getWidth;
}

- (NSInteger)mediaHeight {
    if ([self isVideoAd] && !_adAssets.adImgs.count) {
        return 1280;
    }
    return _adAssets.adImgs.firstObject.getHeight;
}

- (NSString *)buttonText {
    return _adAssets.adButtonText;
}

- (BOOL)isVideoAd {
    return _adAssets.isVideo;
}

@end
