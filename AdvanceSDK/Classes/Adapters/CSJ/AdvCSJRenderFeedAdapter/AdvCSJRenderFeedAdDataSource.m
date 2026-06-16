//
//  AdvCSJRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvCSJRenderFeedAdDataSource.h"

@interface AdvCSJRenderFeedAdDataSource ()
@property (nonatomic, strong) BUMaterialMeta *data;

@end

@implementation AdvCSJRenderFeedAdDataSource

- (instancetype)initWithNativeAdData:(BUMaterialMeta *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (NSString *)title {
    return _data.AdTitle;
}

- (NSString *)desc {
    return _data.AdDescription;
}

- (NSString *)iconUrl {
    return _data.icon.imageURL;
}

- (NSArray *)imageUrlList {
    NSMutableArray *urlList = [NSMutableArray array];
    for (BUImage * image in _data.imageAry) {
        [urlList addObject:image.imageURL];
    }
    return [urlList copy];
}

- (NSInteger)mediaWidth {
    if ([self isVideoAd]) {
        return _data.videoResolutionWidth;
    }
    return _data.imageAry.firstObject.width;
}

- (NSInteger)mediaHeight {
    if ([self isVideoAd]) {
        return _data.videoResolutionHeight;
    }
    return _data.imageAry.firstObject.height;
}

- (NSString *)buttonText {
    return _data.buttonText;
}

- (BOOL)isVideoAd {
    switch (_data.imageMode) {
        case BUFeedVideoAdModeImage:
        case BUFeedVideoAdModePortrait:
        case BUFeedADModeSquareVideo:
        //Live Stream Ad. v5200 add
        case 166:
            return YES;
            
        default:
            return NO;
    }
}

- (NSInteger)videoDuration {
    return _data.videoDuration;
}

- (NSInteger)appRating {
    return _data.score;
}

@end
