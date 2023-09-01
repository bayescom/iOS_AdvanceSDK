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
        @(AdvErrorCode_102) : @"策略请求数据为空",
        @(AdvErrorCode_103) : @"策略请求数据解析错误",
        @(AdvErrorCode_104) : @"策略请求网络状态码错误",
        @(AdvErrorCode_105) : @"策略中未配置渠道，请联系相关运营人员配置",
        @(AdvErrorCode_106) : @"所有平台都未返回广告，请输出description查看详情",
    };
    return [codeMap objectForKey:@(code)];
}

@end
