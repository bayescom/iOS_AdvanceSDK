#import "AdvTKTransport.h"
#import "AdvTKEvent.h"

@interface AdvTKTransport ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation AdvTKTransport

- (instancetype)init {
    return [self initWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
}

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration {
    if (self = [super init]) {
        configuration = [configuration copy];
        configuration.URLCache = nil;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.timeoutIntervalForResource = 15;
        configuration.HTTPMaximumConnectionsPerHost = 3;
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (NSURLSessionDataTask *)sendURL:(NSString *)url timeout:(NSTimeInterval)timeout
                      completion:(AdvTKTransportCompletion)completion {
    if (![AdvTKEvent isValidURLString:url]) {
        completion(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]);
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:timeout];
    request.HTTPMethod = @"GET";
    [request setValue:@"no-cache, no-store" forHTTPHeaderField:@"Cache-Control"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *http = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
        if (!http && !error) error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil];
        completion(http, data, error);
    }];
    [task resume];
    return task;
}

- (void)dealloc {
    [_session invalidateAndCancel];
}

@end
