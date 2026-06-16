//
//  AdvGDTRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvGDTRenderFeedAdDataSource.h"

@interface AdvGDTRenderFeedAdDataSource ()
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *dataObject;

@end

@implementation AdvGDTRenderFeedAdDataSource

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject {
    self = [super init];
    if (self) {
        _dataObject = dataObject;
    }
    return self;
}

- (NSString *)title {
    return _dataObject.title;
}

- (NSString *)desc {
    return _dataObject.desc;
}

- (NSString *)iconUrl {
    return _dataObject.iconUrl;
}

- (NSArray *)imageUrlList {
    if (_dataObject.isThreeImgsAd) {
        return _dataObject.mediaUrlList;
    } else if (_dataObject.imageUrl.length) {
        return @[_dataObject.imageUrl];
    }
    return nil;
}

- (NSInteger)mediaWidth {
    return _dataObject.imageWidth;
}

- (NSInteger)mediaHeight {
    return _dataObject.imageHeight;
}

- (NSString *)buttonText {
    return _dataObject.buttonText;
}

- (BOOL)isVideoAd {
    return [_dataObject isVideoAd] || [_dataObject isVastAd];
}

- (NSInteger)videoDuration {
    return _dataObject.duration;
}

- (NSInteger)appRating {
    return _dataObject.appRating;
}

@end
