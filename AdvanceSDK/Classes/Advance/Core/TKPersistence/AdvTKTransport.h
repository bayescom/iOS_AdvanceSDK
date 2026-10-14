#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AdvTKTransportCompletion)(NSHTTPURLResponse * _Nullable response,
                                         NSData * _Nullable data, NSError * _Nullable error);

@protocol AdvTKTransporting <NSObject>
- (nullable NSURLSessionDataTask *)sendURL:(NSString *)url
                                  timeout:(NSTimeInterval)timeout
                               completion:(AdvTKTransportCompletion)completion;
@end

/// TK 使用独立会话，按 HTTP 响应判断结果，不受业务接口的 MIME/JSON 校验影响。
@interface AdvTKTransport : NSObject <AdvTKTransporting>
- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration;
@end

NS_ASSUME_NONNULL_END
