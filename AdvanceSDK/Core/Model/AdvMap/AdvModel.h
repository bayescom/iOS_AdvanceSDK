
#import <Foundation/Foundation.h>

#if __has_include(<AdvModel/AdvModel.h>)
FOUNDATION_EXPORT double AdvModelVersionNumber;
FOUNDATION_EXPORT const unsigned char AdvModelVersionString[];
#import <AdvModel/NSObject+AdvModel.h>
#import <AdvModel/AdvClassInfo.h>
#else
#import "NSObject+AdvModel.h"
#import "AdvClassInfo.h"
#endif
