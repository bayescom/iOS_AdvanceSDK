//
//  AdvBaseAdapter.h
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import <Foundation/Foundation.h>
#import "AdvanceAdSpotDefine.h"
#import "AdvPolicyService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceBaseAdSpot : NSObject <AdvanceAdSpotDefine, AdvPolicyServiceDelegate>

@end

NS_ASSUME_NONNULL_END
