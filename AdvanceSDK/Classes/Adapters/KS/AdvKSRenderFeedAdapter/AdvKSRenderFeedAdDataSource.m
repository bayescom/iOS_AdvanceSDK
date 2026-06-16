//
//  AdvKSRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvKSRenderFeedAdDataSource.h"

@interface AdvKSRenderFeedAdDataSource ()

@property (nonatomic, strong) KSMaterialMeta *data;

@end

@implementation AdvKSRenderFeedAdDataSource

- (instancetype)initWithNativeAdData:(KSMaterialMeta *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (NSString *)title {
    return _data.appName.length ? _data.appName : _data.productName;
}

- (NSString *)desc {
    return _data.adDescription;
}

- (NSString *)iconUrl {
    return _data.appIconImage.imageURL;
}

- (NSArray *)imageUrlList {
    NSMutableArray *urlList = [NSMutableArray array];
    for (KSAdImage * image in _data.imageArray) {
        [urlList addObject:image.imageURL];
    }
    return [urlList copy];
}

- (NSInteger)mediaWidth {
    if ([self isVideoAd]) {
        return _data.videoCoverImage.width;
    }
    return _data.imageArray.firstObject.width;
}

- (NSInteger)mediaHeight {
    if ([self isVideoAd]) {
        return _data.videoCoverImage.height;
    }
    return _data.imageArray.firstObject.height;
}

- (NSString *)buttonText {
    return _data.actionDescription;
}

- (BOOL)isVideoAd {
    return _data.materialType == KSAdMaterialTypeVideo;
}

- (NSInteger)videoDuration {
    return _data.videoDuration;
}

- (NSInteger)appRating {
    return _data.appScore;
}

@end
