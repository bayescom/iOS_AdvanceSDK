//
//  AdvBaiduRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvBaiduRenderFeedAdDataSource.h"

@interface AdvBaiduRenderFeedAdDataSource ()
@property (nonatomic, strong) BaiduMobAdNativeAdObject *dataObject;

@end

@implementation AdvBaiduRenderFeedAdDataSource

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject {
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
    return _dataObject.text;
}

- (NSString *)iconUrl {
    return _dataObject.iconImageURLString;
}

- (NSArray *)imageUrlList {
    if (_dataObject.morepics.count) { // 三图
        return _dataObject.morepics;
    } else if (_dataObject.mainImageURLString.length) { // 单图
        return @[_dataObject.mainImageURLString];
    }
    return nil;
}

- (NSInteger)mediaWidth {
    return _dataObject.w.integerValue;
}

- (NSInteger)mediaHeight {
    return _dataObject.h.integerValue;
}

- (NSString *)buttonText {
    return _dataObject.actButtonString;
}

- (BOOL)isVideoAd {
    return _dataObject.materialType == VIDEO;
}

- (NSInteger)videoDuration {
    return _dataObject.videoDuration.integerValue;
}

@end
