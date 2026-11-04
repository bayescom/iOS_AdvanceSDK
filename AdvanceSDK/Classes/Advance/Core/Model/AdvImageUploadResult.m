#import "AdvImageUploadResult.h"

@implementation AdvNetworkImageFile

- (instancetype)initWithData:(NSData *)data fileName:(NSString *)fileName {
    if (self = [super init]) {
        _data = [data copy];
        _fileName = [fileName copy];
    }
    return self;
}

@end

@implementation AdvImageUploadResult
@end
