//
//  AdvFunlinkRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvFunlinkRenderFeedAdDataSource.h"

@interface AdvFunlinkRenderFeedAdDataSource ()
@property (nonatomic, strong) FLinkFeedAdData *data;

@end

@implementation AdvFunlinkRenderFeedAdDataSource

- (instancetype)initWithAdData:(FLinkFeedAdData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (NSString *)title {
    return _data.adTitle;
}

- (NSString *)desc {
    return _data.adContent;
}

- (NSString *)iconUrl {
    return _data.iconUrl;
}

- (NSArray *)imageUrlList {
    if (_data.imageUrl.length) {
        return @[_data.imageUrl];
    } else if (_data.mediaUrlList.count) {
        return _data.mediaUrlList;
    }
    return nil;
}

- (NSInteger)mediaWidth {
    if ([self isVideoAd]) {
        return _data.videoWidth;
    }
    return _data.imageWidth;
}

- (NSInteger)mediaHeight {
    if ([self isVideoAd]) {
        return _data.videoHeight;
    }
    return _data.imageHeight;
}

- (NSString *)buttonText {
    return _data.buttonText;
}

- (BOOL)isVideoAd {
    return _data.isVideoAd;
}

- (NSInteger)videoDuration {
    return _data.videoDuration;
}

@end
