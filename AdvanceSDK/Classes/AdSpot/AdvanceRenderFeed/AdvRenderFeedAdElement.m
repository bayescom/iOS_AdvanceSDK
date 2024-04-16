//
//  AdvRenderFeedAdElement.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvRenderFeedAdElement.h"

@implementation AdvRenderFeedAdElement

- (NSString *)buttonText {
    if (!_buttonText) {
        return @"查看详情";
    }
    return _buttonText;
}

@end
