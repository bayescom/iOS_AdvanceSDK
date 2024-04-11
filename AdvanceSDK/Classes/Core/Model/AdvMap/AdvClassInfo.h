
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, AdvEncodingType) {
    AdvEncodingTypeMask       = 0xFF, ///< mask of type value
    AdvEncodingTypeUnknown    = 0, ///< unknown
    AdvEncodingTypeVoid       = 1, ///< void
    AdvEncodingTypeBool       = 2, ///< bool
    AdvEncodingTypeInt8       = 3, ///< char / BOOL
    AdvEncodingTypeUInt8      = 4, ///< unsigned char
    AdvEncodingTypeInt16      = 5, ///< short
    AdvEncodingTypeUInt16     = 6, ///< unsigned short
    AdvEncodingTypeInt32      = 7, ///< int
    AdvEncodingTypeUInt32     = 8, ///< unsigned int
    AdvEncodingTypeInt64      = 9, ///< long long
    AdvEncodingTypeUInt64     = 10, ///< unsigned long long
    AdvEncodingTypeFloat      = 11, ///< float
    AdvEncodingTypeDouble     = 12, ///< double
    AdvEncodingTypeLongDouble = 13, ///< long double
    AdvEncodingTypeObject     = 14, ///< id
    AdvEncodingTypeClass      = 15, ///< Class
    AdvEncodingTypeSEL        = 16, ///< SEL
    AdvEncodingTypeBlock      = 17, ///< block
    AdvEncodingTypePointer    = 18, ///< void*
    AdvEncodingTypeStruct     = 19, ///< struct
    AdvEncodingTypeUnion      = 20, ///< union
    AdvEncodingTypeCString    = 21, ///< char*
    AdvEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    AdvEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    AdvEncodingTypeQualifierConst  = 1 << 8,  ///< const
    AdvEncodingTypeQualifierIn     = 1 << 9,  ///< in
    AdvEncodingTypeQualifierInout  = 1 << 10, ///< inout
    AdvEncodingTypeQualifierOut    = 1 << 11, ///< out
    AdvEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    AdvEncodingTypeQualifierByref  = 1 << 13, ///< byref
    AdvEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    AdvEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    AdvEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    AdvEncodingTypePropertyCopy         = 1 << 17, ///< copy
    AdvEncodingTypePropertyRetain       = 1 << 18, ///< retain
    AdvEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    AdvEncodingTypePropertyWeak         = 1 << 20, ///< weak
    AdvEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    AdvEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    AdvEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

AdvEncodingType AdvEncodingGetType(const char *typeEncoding);

@interface AdvClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) AdvEncodingType type;    ///< Ivar's type

- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface AdvClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface AdvClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) AdvEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 Class information for a class.
 */
@interface AdvClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) AdvClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, AdvClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, AdvClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, AdvClassPropertyInfo *> *propertyInfos; ///< properties
- (void)setNeedUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
