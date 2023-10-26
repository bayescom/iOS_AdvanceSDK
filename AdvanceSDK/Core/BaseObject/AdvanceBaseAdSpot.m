//
//  AdvBaseAdapter.m
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvLog.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation AdvanceBaseAdSpot

@synthesize mediaId = _mediaId;
@synthesize adspotid = _adspotid;
@synthesize ext = _ext;
@synthesize viewController = _viewController;
@synthesize adapterMap = _adapterMap;
@synthesize targetAdapter = _targetAdapter;
@synthesize manager = _manager;
@synthesize isGroMoreADN = _isGroMoreADN;

- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotid
                      customExt:(NSDictionary *)ext {
    if (self = [super init]) {
        _mediaId = mediaId;
        _adspotid = adspotid;
        _ext = ext;
        _manager = [AdvPolicyService manager];
        _manager.delegate = self;
        _adapterMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadAdPolicy {
    [_manager loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

- (void)catchBidTargetWhenGroMoreBiddingWithPolicyModel:(AdvPolicyModel *)model {
    [_manager catchBidTargetWhenGroMoreBiddingWithPolicyModel:model];
}

- (void)dealloc {
    ADVLog(@"%s %@", __func__, self);
}

@end
