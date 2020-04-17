//
//  SdkSupplier.m
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "SdkSupplier.h"

@implementation SdkSupplier

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid mediaKey:(NSString *)mediakey sdkTag:(NSString *)sdkTag {
    if (self = [super init]) {

        _mediaid = mediaid;
        _adspotid = adspotid;
        _mediakey = mediakey;
        _sdkTag = sdkTag;
        _id = @"0";
        _adCount = 1;
        _name = @"默认SDK";
        _priority = 1;
        _timeout = 5000;
    }
    return self;
}

+ (void)sortByPriority:(NSMutableArray<SdkSupplier *> *)sdkList {
    if (sdkList) {
        [sdkList sortWithOptions:NSSortStable usingComparator:
                ^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                    SdkSupplier *obj11 = obj1;
                    SdkSupplier *obj22 = obj2;
                    if (obj11.priority > obj22.priority) {
                        return NSOrderedDescending;
                    } else if (obj11.priority == obj22.priority) {
                        return NSOrderedSame;
                    } else {
                        return NSOrderedAscending;
                    }
                }];
    }
}

@end
