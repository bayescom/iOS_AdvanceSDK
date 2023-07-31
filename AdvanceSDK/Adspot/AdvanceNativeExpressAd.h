//
//  AdvanceNativeExpressAd.h
//  AdvanceSDK
//
//  Created by MS on 2021/8/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceNativeExpressAd : NSObject

- (instancetype)initWithViewController:(UIViewController *)controller;
// 信息流view
@property (nonatomic, strong) UIView *expressView;

// 渠道标识
@property (nonatomic, copy) NSString *identifier;

// 该信息流广告的价格;
@property (nonatomic, assign) NSInteger price;

///  设定是否静音播放视频，YES = 静音，NO = 非静音 默认为YES
/*
PS:
①仅gdt、ks、支持设定mute
②仅适用于视频播放器设定生效
 (只对客户端可以控制的部分生效, 有些需要到网盟后台去设置比如穿山甲)
重点：请在loadAd前设置,否则不生效
*/

@property(nonatomic, assign) BOOL muted;

// 是否停止该信息流view的摇一摇 该属性支队MercurySDK 的信息流有效果
// 该属性在拉取成功广告数据成功后 设置才有效
// 如果信息流有摇一摇的话, 开发者可手动置为 YES; 此时该视图便不在响应摇一摇
// 例如: 在信息流广告所载的vc上弹出了一个开发者自定义的弹窗, 此时想禁用摇一摇, 可设置为YES ,
// 在适当的时候 可以设置为NO 恢复摇一摇
// 注意: 这只是暂时不让该信息流view响应摇一摇, 内部仍然在监听摇动!!!!!!!!
@property (nonatomic, assign) BOOL isStopMotion;

- (void)render;

@end

NS_ASSUME_NONNULL_END
