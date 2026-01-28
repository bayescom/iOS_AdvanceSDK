//
//  AdvRenderFeedAdElement.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvRenderFeedAdElement.h"
#import "AdvLog.h"

@implementation AdvRenderFeedAdElement

- (NSString *)buttonText {
    if (!_buttonText) {
        return @"查看详情";
    }
    return _buttonText;
}

- (BOOL)isAdValid {
    if (!_isAdValid) {
        AdvLog(@"[show]广告展示前广告已失效过期");
    }
    return _isAdValid;
}

@end
