
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AdvModel)

+ (nullable instancetype)adv_modelWithJSON:(id)json;

+ (nullable instancetype)adv_modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)adv_modelSetWithJSON:(id)json;

- (BOOL)adv_modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)adv_modelToJSONObject;

- (nullable NSData *)adv_modelToJSONData;

- (nullable NSString *)adv_modelToJSONString;

- (nullable id)adv_modelCopy;

- (void)adv_modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)adv_modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)adv_modelHash;

- (BOOL)adv_modelIsEqual:(id)model;

- (NSString *)adv_modelDescription;

@end

@interface NSArray (AdvModel)

+ (nullable NSArray *)adv_modelArrayWithClass:(Class)cls json:(id)json;

@end

@interface NSDictionary (AdvModel)

+ (nullable NSDictionary *)adv_modelDictionaryWithClass:(Class)cls json:(id)json;
@end

@protocol AdvModel <NSObject>
@optional

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
