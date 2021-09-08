//
//  AdvTrackEventDelegate.h
//  Pods
//
//  Created by MS on 2021/9/8.
//

#import <Foundation/Foundation.h>

@protocol AdvTrackEventDelegate <NSObject>
- (void)trackAdvEvent:(NSString *)event withParameters:(NSDictionary *)parameters;
@end
