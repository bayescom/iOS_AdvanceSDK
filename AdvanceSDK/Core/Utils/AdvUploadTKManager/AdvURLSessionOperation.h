//
//  AdvURLSessionOperation.h
//  AdvanceSDK
//
//  Created by MS on 2021/8/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvURLSessionOperation : NSOperation

- (instancetype)initWithSession:(NSURLSession *)session URL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

@property (nonatomic, strong, readonly) NSURLSessionDataTask *task;


@end

NS_ASSUME_NONNULL_END
