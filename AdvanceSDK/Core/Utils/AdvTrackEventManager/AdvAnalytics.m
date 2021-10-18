#import "AdvAnalytics.h"
#import <objc/runtime.h>
#import <objc/message.h>

static NSMutableDictionary *advEventDetails() {
    static NSMutableDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static NSMutableDictionary *advSelectorEvents() {
    static NSMutableDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

static SEL Adv_selectorForOriginSelector(SEL selector) {
    return NSSelectorFromString([NSStringFromSelector(selector) stringByAppendingString:@"__Adv"]);
}

static NSString *Adv_strForClassAndSelector(Class klass, SEL selector) {
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass(klass), NSStringFromSelector(selector)];
}

static NSArray *Adv_parametersForInvocation(NSInvocation *invocation) {
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *argumentsArray = [NSMutableArray arrayWithCapacity:numberOfArguments - 2];
    for (NSUInteger index = 2; index < numberOfArguments; index++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:index];
        #define WRAP_AND_RETURN(type) \
        do { \
            type val = 0; \
            [invocation getArgument:&val atIndex:(NSInteger)index]; \
            [argumentsArray addObject:@(val)]; \
        } while (0)
        if (strcmp(argumentType, @encode(id)) == 0 || strcmp(argumentType, @encode(Class)) == 0) {
            __autoreleasing id returnObj;
            [invocation getArgument:&returnObj atIndex:(NSInteger)index];
            [argumentsArray addObject:returnObj];
        } else if (strcmp(argumentType, @encode(char)) == 0) {
            WRAP_AND_RETURN(char);
        } else if (strcmp(argumentType, @encode(int)) == 0) {
            WRAP_AND_RETURN(int);
        } else if (strcmp(argumentType, @encode(short)) == 0) {
            WRAP_AND_RETURN(short);
        } else if (strcmp(argumentType, @encode(long)) == 0) {
            WRAP_AND_RETURN(long);
        } else if (strcmp(argumentType, @encode(long long)) == 0) {
            WRAP_AND_RETURN(long long);
        } else if (strcmp(argumentType, @encode(unsigned char)) == 0) {
            WRAP_AND_RETURN(unsigned char);
        } else if (strcmp(argumentType, @encode(unsigned int)) == 0) {
            WRAP_AND_RETURN(unsigned int);
        } else if (strcmp(argumentType, @encode(unsigned short)) == 0) {
            WRAP_AND_RETURN(unsigned short);
        } else if (strcmp(argumentType, @encode(unsigned long)) == 0) {
            WRAP_AND_RETURN(unsigned long);
        } else if (strcmp(argumentType, @encode(unsigned long long)) == 0) {
            WRAP_AND_RETURN(unsigned long long);
        } else if (strcmp(argumentType, @encode(float)) == 0) {
            WRAP_AND_RETURN(float);
        } else if (strcmp(argumentType, @encode(double)) == 0) {
            WRAP_AND_RETURN(double);
        } else if (strcmp(argumentType, @encode(BOOL)) == 0) {
            WRAP_AND_RETURN(BOOL);
        } else if (strcmp(argumentType, @encode(char *)) == 0) {
            WRAP_AND_RETURN(const char *);
        } else if (strcmp(argumentType, @encode(void (^)(void))) == 0) {
            __unsafe_unretained id block = nil;
            [invocation getArgument:&block atIndex:(NSInteger)index];
            if (block) {
                [argumentsArray addObject:[block copy]];
            } else {
                [argumentsArray addObject:[NSNull null]];
            }
        } else {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(argumentType, &valueSize, NULL);
            
            unsigned char valueBytes[valueSize];
            [invocation getArgument:valueBytes atIndex:(NSInteger)index];
            
            [argumentsArray addObject:[NSValue valueWithBytes:valueBytes objCType:argumentType]];
        }
    }
    return [argumentsArray copy];
}

static void AdvForwardInvocation(__unsafe_unretained id assignSlf, SEL selector, NSInvocation *invocation) {
    NSArray *events = advSelectorEvents()[Adv_strForClassAndSelector([assignSlf class], invocation.selector)];
    [events enumerateObjectsUsingBlock:^(NSString *eventName, NSUInteger idx, BOOL *stop) {
        NSDictionary *detail = advEventDetails()[eventName];
        NSArray *argumentsArray = Adv_parametersForInvocation(invocation);
        BOOL (^shouldExecuteBlock)(id object, NSArray *parameters) = detail[AdvAnalyticsShouldExecute];
        NSDictionary *(^parametersBlock)(id object, NSArray *parameters) = detail[AdvAnalyticsParameters];
        if (shouldExecuteBlock == nil || shouldExecuteBlock(assignSlf, argumentsArray)) {
            [[AdvAnalytics shared].provider trackAdvEvent:eventName withParameters:parametersBlock(assignSlf, argumentsArray)];
        }
    }];
    SEL newSelector = Adv_selectorForOriginSelector(invocation.selector);
    invocation.selector = newSelector;
    [invocation invoke];
}

@implementation AdvAnalytics
// MARK: ======================= 初始化设置 =======================
static AdvAnalytics *analytics = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analytics = [[AdvAnalytics alloc] init];
    });
    return analytics;
}


+ (id)allocWithZone:(struct _NSZone *)zone {
   static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(analytics == nil) {
            analytics = [super allocWithZone:zone];
        }
    });
    return analytics;
}

//自定义初始化方法
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
    return @"这是倍业聚合SDK中用于统计自定义事件的组件";
}

// MARK: ======================= Methods =======================


- (void)configure:(NSDictionary *)configurationDictionary provider:(id<AdvAnalyticsProvider>)provider {
    self.provider = provider;
    NSArray *trackedMethodCallEventClasses = configurationDictionary[AdvAnalyticsMethodCall];
    [trackedMethodCallEventClasses enumerateObjectsUsingBlock:^(NSDictionary *eventDictionary, NSUInteger idx, BOOL *stop) {
        [self __addMethodCallEventAnalyticsHook:eventDictionary];
    }];
}

- (void)__addMethodCallEventAnalyticsHook:(NSDictionary *)eventDictionary {
    Class klass = eventDictionary[AdvAnalyticsClass];
    [eventDictionary[AdvAnalyticsDetails] enumerateObjectsUsingBlock:^(id dict, NSUInteger idx, BOOL *stop) {
        NSString *selectorName = dict[AdvAnalyticsSelector];
        SEL originSelector = NSSelectorFromString(selectorName);
        Method originMethod = class_getInstanceMethod(klass, originSelector);
        const char *typeEncoding = method_getTypeEncoding(originMethod);
        
        SEL newSelector = Adv_selectorForOriginSelector(originSelector);
        class_addMethod(klass, newSelector, method_getImplementation(originMethod), typeEncoding);
        
        class_replaceMethod(klass, originSelector, _objc_msgForward, typeEncoding);
        
        if (class_getMethodImplementation(klass, @selector(forwardInvocation:)) != (IMP)AdvForwardInvocation) {
            class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)AdvForwardInvocation, "v@:@");
        }
        
        NSMutableDictionary *detailDict = [dict mutableCopy];
        [detailDict removeObjectForKey:AdvAnalyticsEvent];
        [advEventDetails() setObject:detailDict forKey:dict[AdvAnalyticsEvent]];
        
        NSString *selectorKey = Adv_strForClassAndSelector(klass, originSelector);
        NSMutableArray *events = advSelectorEvents()[selectorKey];
        if (!events) events = [NSMutableArray new];
        [events addObject:dict[AdvAnalyticsEvent]];
        [advSelectorEvents() setObject:events forKey:selectorKey];
    }];
}

@end