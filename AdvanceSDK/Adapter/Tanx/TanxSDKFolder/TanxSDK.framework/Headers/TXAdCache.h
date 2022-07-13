//
//  TXAdCache.h
//  TanxCoreSDK
//
//  Created by XY on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import <TanxSDK/TXAdEnum.h>


NS_ASSUME_NONNULL_BEGIN

@interface TXAdCache : NSObject

@property(nonatomic, copy) NSString *splashId;
@property(nonatomic, copy) NSString *creativeId;
@property(nonatomic, copy) NSString *templateId;
@property(nonatomic, copy) NSString *reqId;
@property(nonatomic, copy) NSString *seatId;
@property(nonatomic, copy) NSString *pid;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) TXAdType adType;


- (BOOL)isValid;

- (NSInteger)rst;
- (void)setRst:(NSInteger)rst;

@end

NS_ASSUME_NONNULL_END
