//
//  TXAdMonitor.h
//  TanxSDK
//
//  Created by Yueyang Gu on 2022/5/17.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXAdMonitor : JSONModel

@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *templateId;
@property (nonatomic, copy) NSString *reqId;
@property (nonatomic, copy) NSString *creativeId;
@property (nonatomic, copy)         NSArray            *url;
@property (nonatomic, assign)       NSInteger           type;
@property (nonatomic, assign)       NSInteger           sdk;
@property (nonatomic, assign)       NSInteger           time;

- (instancetype)initWithPid:(NSString *)pid templateId:(NSString *)templateId reqId:(NSString *)reqId creativeId:(NSString *)creativeId url:(NSArray<NSString *> *)url;

@end

NS_ASSUME_NONNULL_END
