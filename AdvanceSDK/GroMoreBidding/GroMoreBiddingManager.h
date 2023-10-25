//
//  GroMoreBiddingManager.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroMoreBiddingManager : NSObject

@property (nonatomic, strong, class) AdvPolicyModel *policyModel;

+ (void)loadGroMoreSDKWithDataObject:(AdvPolicyModel *)dataObject;

@end

NS_ASSUME_NONNULL_END
