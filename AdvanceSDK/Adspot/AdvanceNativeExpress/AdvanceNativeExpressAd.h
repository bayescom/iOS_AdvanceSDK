//
//  AdvanceNativeExpressAd.h
//  AdvanceSDK
//
//  Created by MS on 2021/8/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceNativeExpressAd : NSObject

// 信息流view
@property (nonatomic, strong) UIView *expressView;
// 渠道标识
@property (nonatomic, copy) NSString *identifier;
// tanx Ad Model
@property (nonatomic, strong) id tanxAdModel;


@end

NS_ASSUME_NONNULL_END
