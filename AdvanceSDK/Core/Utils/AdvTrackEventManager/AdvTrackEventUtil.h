//
//  AdvTrackEventUtil.h
//  AdvanceSDK
//
//  Created by MS on 2021/9/9.
//

#import <Foundation/Foundation.h>
#import "AdvTrackEventParameters.h"
NS_ASSUME_NONNULL_BEGIN


#define ADVTRACK(mediaId, adspodId, case) [[[AdvTrackEventUtil alloc]initUtilWithMediaId:mediaId adspotId:adspodId] advTrackEventActionWithCase:case]

@interface AdvTrackEventUtil : NSObject
- (instancetype)initUtilWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId;

- (void)advTrackEventActionWithCase:(AdvTrackEventCase)eventCase;
@end

NS_ASSUME_NONNULL_END
