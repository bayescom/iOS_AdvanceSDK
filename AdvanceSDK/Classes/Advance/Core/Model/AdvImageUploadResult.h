#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvNetworkImageFile : NSObject

@property (nonatomic, copy, readonly) NSData *data;
@property (nonatomic, copy, readonly) NSString *fileName;

- (instancetype)initWithData:(NSData *)data fileName:(NSString *)fileName NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface AdvImageUploadResult : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSArray<NSString *> *urls;
@property (nonatomic, copy) NSArray<NSDictionary *> *failed;
@property (nonatomic, assign) NSInteger success_count;
@property (nonatomic, assign) NSInteger fail_count;
@property (nonatomic, assign) NSInteger total;

@end

NS_ASSUME_NONNULL_END
