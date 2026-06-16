//
//  AdvMercuryRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvMercuryRenderFeedAdDataSource.h"

@interface AdvMercuryRenderFeedAdDataSource ()
@property (nonatomic, strong) MercuryUnifiedNativeAdDataObject *dataObject;

@end

@implementation AdvMercuryRenderFeedAdDataSource

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject {
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
        return _dataObject.imageUrlList;
    } else if (_dataObject.imageUrl.length) {
        return @[_dataObject.imageUrl];
    }
    return nil;
}

- (NSInteger)mediaWidth {
    return _dataObject.mediaWidth;
}

- (NSInteger)mediaHeight {
    return _dataObject.mediaHeight;
}

- (NSString *)buttonText {
    return _dataObject.buttonText;
}

- (BOOL)isVideoAd {
    return [_dataObject isVideoAd];
}

@end
