//
//  DemoListFeedExpressViewController.h
//  Example
//
//  Created by CherryKing on 2019/11/21.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoListFeedExpressViewController : UIViewController
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, strong) NSDictionary *ext;
@end

NS_ASSUME_NONNULL_END
