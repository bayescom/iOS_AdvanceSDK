//
//  AdvError.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvError.h"

@interface AdvError ()
@property (nonatomic, assign) AdvErrorCode code;
@property (nonatomic, copy) NSString *message;

@end

@implementation AdvError

+ (instancetype)errorWithCode:(AdvErrorCode)code {
    return [self errorWithCode:code message:[AdvError errorCodeDescMap:code]];
}

+ (instancetype)errorWithCode:(NSInteger)code message:(NSString *)message {
    AdvError *advErr = [[AdvError alloc] init];
    advErr.code = code;
    advErr.message = message;
    return advErr;
}

- (NSError *)toNSError {
    NSError *error = [NSError errorWithDomain:@"com.advance.error"
                                         code:self.code
                                     userInfo:@{NSLocalizedDescriptionKey:self.message ?: @""}];
    return error;
}

+ (NSString *)errorCodeDescMap:(AdvErrorCode)code {
    NSDictionary *codeMap = @{
        @(AdvErrorCode_SDKInitException) : @"SDK初始化失败",
        @(AdvErrorCode_Timeout) : @"策略请求超时",
        @(AdvErrorCode_NetworkError) : @"网络层异常",
        @(AdvErrorCode_NoNetwork) : @"无网络",
        @(AdvErrorCode_ResponseTypeError) : @"策略返回数据类型错误",
        @(AdvErrorCode_NoneSupplier) : @"策略中未配置渠道，请联系相关运营人员配置",
        @(AdvErrorCode_ParseModelError) : @"策略返回数据模型解析失败",
        @(AdvErrorCode_Not200) : @"策略接口服务器返回Code值非200",
        @(AdvErrorCode_SupplierTimeout) : @"渠道广告加载超时",
        @(AdvErrorCode_InvalidExpired) : @"广告展示前广告已失效过期",
        @(AdvErrorCode_AllLoadAdFailed) : @"所有平台都未返回广告（失败或超时）",
        @(AdvErrorCode_SupplierUninstalled) : @"所有渠道SDK都未安装",
//        @(AdvErrorCode_SupplierInitFailed) : @"渠道SDK初始化失败",
    };
    return [codeMap objectForKey:@(code)];
}

@end
