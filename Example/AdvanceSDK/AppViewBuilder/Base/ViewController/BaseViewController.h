//
//  BaseViewController.h
//  Example
//
//  Created by CherryKing on 2019/12/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDStatusBarNotification.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property (nonatomic, assign) BOOL initDefSubviewsFlag;
@property (nonatomic, copy, readonly) NSString *mediaId;
@property (nonatomic, copy, readonly) NSString *adspotId;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *ext;
@property (nonatomic, strong, readonly) UIView *adShowView;
@property (nonatomic, strong, readonly) UIView *cusView;

@property (nonatomic, copy) NSString *btn1Title;
@property (nonatomic, copy) NSString *btn2Title;

/// 广告位ID描述 @"addesc" : @"adspotId", @"id"
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *adspotIdsArr;

/// 覆盖此方法实现点击加载广告事件
- (void)loadAdBtn1Action;
- (void)loadAdBtn2Action;

/// 确认写了 广告位Id
- (BOOL)checkAdspotId;


- (void)resignFirstResponder;
@end

NS_ASSUME_NONNULL_END
