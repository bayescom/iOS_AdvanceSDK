//
//  AdvError.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvError.h"

@interface AdvError ()
@property (nonatomic, assign) AdvErrorCode code;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) id obj;

@end

@implementation AdvError

+ (instancetype)errorWithCode:(AdvErrorCode)code {
    return [self errorWithCode:code obj:@""];
}

+ (instancetype)errorWithCode:(AdvErrorCode)code obj:(id)obj {
    AdvError *advErr = [[AdvError alloc] init];
    advErr.code = code;
    advErr.desc = [AdvError errorCodeDescMap:code];
    advErr.obj = obj;
    return advErr;
}

- (NSError *)toNSError {
    if (self.obj == nil) { self.obj = @""; }
    if (self.desc == nil) { self.desc = @""; }
    NSError *error = [NSError errorWithDomain:@"com.Advance.Error" code:self.code userInfo:@{
        @"desc": self.desc,
        @"obj": self.obj,
    }];
    return error;
}

+ (NSString *)errorCodeDescMap:(AdvErrorCode)code {
    NSDictionary *codeMap = @{
        @(AdvErrorCode_101) : @"策略请求失败",
        @(AdvErrorCode_102) : @"策略请求返回失败",
        @(AdvErrorCode_103) : @"策略请求网络状态码错误",
        @(AdvErrorCode_104) : @"策略请求返回内容解析错误",
        @(AdvErrorCode_105) : @"策略请求网络状态码错误",
        @(AdvErrorCode_110) : @"未设置打底渠道",
        @(AdvErrorCode_111) : @"CPT但本地无策略",
        @(AdvErrorCode_112) : @"本地有策略但未命中CPT目标渠道",
        @(AdvErrorCode_113) : @"非CPT本地无策略",
        @(AdvErrorCode_114) : @"非CPT本地策略都执行失败",
        @(AdvErrorCode_115) : @"请求超出设定总时长",
        @(AdvErrorCode_116) : @"策略中未配置渠道",
    };
    return [codeMap objectForKey:@(code)];
}

@end
