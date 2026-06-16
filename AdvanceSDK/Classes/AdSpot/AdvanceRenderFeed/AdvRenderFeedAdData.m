//
//  AdvRenderFeedAdData.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvRenderFeedAdData.h"
#import "AdvRenderFeedAdDataSource.h"

@interface AdvRenderFeedAdData ()
@property (nonatomic, strong) id<AdvRenderFeedAdDataSource> dataSource;

@end

@implementation AdvRenderFeedAdData

- (instancetype)initWithDataSource:(id<AdvRenderFeedAdDataSource>)dataSource {
    if (self = [super init]) {
        _dataSource = dataSource;
    }
    return self;
}

- (NSString *)title {
    if ([_dataSource respondsToSelector:@selector(title)]) {
        return _dataSource.title;
    }
    return nil;
}

- (NSString *)desc {
    if ([_dataSource respondsToSelector:@selector(desc)]) {
        return _dataSource.desc;
    }
    return nil;
}

- (NSString *)iconUrl {
    if ([_dataSource respondsToSelector:@selector(iconUrl)]) {
        return _dataSource.iconUrl;
    }
    return nil;
}

- (NSArray *)imageUrlList {
    if ([_dataSource respondsToSelector:@selector(imageUrlList)]) {
        return _dataSource.imageUrlList;
    }
    return nil;
}

- (NSInteger)mediaWidth {
    if ([_dataSource respondsToSelector:@selector(mediaWidth)]) {
        return _dataSource.mediaWidth ?: 1;
    }
    return 1;
}

- (NSInteger)mediaHeight {
    if ([_dataSource respondsToSelector:@selector(mediaHeight)]) {
        return _dataSource.mediaHeight ?: 1;
    }
    return 1;
}

- (NSString *)buttonText {
    if ([_dataSource respondsToSelector:@selector(buttonText)]) {
        return _dataSource.buttonText.length ? _dataSource.buttonText : @"查看详情";
    }
    return @"查看详情";
}

- (BOOL)isVideoAd {
    if ([_dataSource respondsToSelector:@selector(isVideoAd)]) {
        return _dataSource.isVideoAd;
    }
    return NO;
}

- (NSInteger)videoDuration {
    if ([_dataSource respondsToSelector:@selector(videoDuration)]) {
        return _dataSource.videoDuration;
    }
    return 0;
}

- (NSInteger)appRating {
    if ([_dataSource respondsToSelector:@selector(appRating)]) {
        return _dataSource.appRating;
    }
    return 0;
}

@end
