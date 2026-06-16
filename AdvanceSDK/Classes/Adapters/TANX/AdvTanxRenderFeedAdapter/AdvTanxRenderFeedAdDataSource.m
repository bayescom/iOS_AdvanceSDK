//
//  AdvTanxRenderFeedAdDataSource.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvTanxRenderFeedAdDataSource.h"

@interface AdvTanxRenderFeedAdDataSource ()
@property (nonatomic, strong) TXAdModel *adModel;
@property (nonatomic, strong) NSDictionary *data;

@end

@implementation AdvTanxRenderFeedAdDataSource

- (instancetype)initWithAdModel:(TXAdModel *)adModel {
    if (self = [super init]) {
        _adModel = adModel;
        _data = adModel.adMaterialDict;
    }
    return self;
}

- (NSString *)title {
    return _data[@"title"];
}

- (NSString *)desc {
    return _data[@"description"];
}

- (NSString *)iconUrl {
    return _data[@"smImageUrl"];
}

- (NSArray *)imageUrlList {
    return @[_data[@"assetUrl"] ?: @""];
}

- (NSInteger)mediaWidth {
    if ([self isVideoAd]) {
        return [_data[@"videoWidth"] integerValue];
    }
    return [_data[@"width"] integerValue];
}

- (NSInteger)mediaHeight {
    if ([self isVideoAd]) {
        return [_data[@"videoHeight"] integerValue];
    }
    return [_data[@"height"] integerValue];
}

- (BOOL)isVideoAd {
    return _adModel.adType == TanXAdTypeFeedVideo;
}

@end
