//
//  AdvUploadTKManager.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/20.
//

#import "AdvUploadTKManager.h"

@implementation AdvUploadTKManager

static AdvUploadTKManager *defaultManager = nil;

+ (AdvUploadTKManager*)defaultManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil) {
            defaultManager = [[self alloc] init];
        }
    });
    return defaultManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
   static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil) {
            defaultManager = [super allocWithZone:zone];
        }
    });
    return defaultManager;
}
//自定义初始化方法，本例中只有name这一属性
- (instancetype)init {
    self = [super init];
    if(self) {

    }
    return self;
}

//覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
- (id)copy {
    return self;
}

//覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
- (id)mutableCopy {
    return self;
}
//自定义描述信息，用于log详细打印
- (NSString *)description {
    return @"这是倍业聚合SDK中用于上传各广告位生命周期的组件";
}

@end
