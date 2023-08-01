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

// 该信息流广告的价格;
@property (nonatomic, assign) NSInteger price;

// 是否停止该信息流view的摇一摇 该属性支队MercurySDK 的信息流有效果
// 该属性在拉取成功广告数据成功后 设置才有效
// 如果信息流有摇一摇的话, 开发者可手动置为 YES; 此时该视图便不在响应摇一摇
// 例如: 在信息流广告所载的vc上弹出了一个开发者自定义的弹窗, 此时想禁用摇一摇, 可设置为YES ,
// 在适当的时候 可以设置为NO 恢复摇一摇
// 注意: 这只是暂时不让该信息流view响应摇一摇, 内部仍然在监听摇动!!!!!!!!
@property (nonatomic, assign) BOOL isStopMotion;

- (instancetype)initWithViewController:(UIViewController *)controller;

- (void)render;

@end

NS_ASSUME_NONNULL_END
