//
//  GDTSDKConfig.h
//  GDTMobApp
//
//  Created by GaoChao on 14/8/25.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTSDKDefines.h"

@interface GDTSDKConfig : NSObject
/**
 * 提供给聚合平台用来设定SDK 流量分类
 */
+ (void)setSdkSrc:(NSString *)sdkSrc;

/**
 * 查看SDK流量来源
 */
+ (NSString *)sdkSrc;



/**
 * 获取 SDK 版本
 */

+ (NSString *)sdkVersion;

+ (void)enableGPS:(BOOL)enabled;

/**
* 设置流量渠道号
 渠道号信息主要用来协助平台提升流量变现效果及您的收益，请如实填写，若渠道号无法满足您的诉求请联系平台负责商务
 
 渠道号映射关系为：
 1：百度
 2：头条
 3：广点通
 4：搜狗
 5：其他网盟
 6：oppo
 7：vivo
 8：华为
 9：应用宝
 10：小米
 11：金立
 12：百度手机助手
 13：魅族
 14：AppStore
 999：其他
*/
+ (void)setChannel:(NSInteger)channel;

+ (void)setSDKType:(NSInteger)type;

@end
