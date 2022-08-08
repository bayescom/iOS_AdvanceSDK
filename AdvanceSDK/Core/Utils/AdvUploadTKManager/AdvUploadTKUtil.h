//
//  AdvUploadTKUtil.h
//  AdvanceSDK
//
//  Created by MS on 2021/8/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvUploadTKUtil : NSObject
@property (nonatomic, assign) NSTimeInterval serverTime;
@property (nonatomic, copy) NSString *reqid;

- (NSMutableArray *)loadedtkUrlWithArr:(NSArray<NSString *> *)uploadArr;

- (NSMutableArray *)succeedtkUrlWithArr:(NSArray<NSString *> *)uploadArr price:(NSInteger)price;

- (NSMutableArray *)imptkUrlWithArr:(NSArray<NSString *> *)uploadArr price:(NSInteger)price;

- (NSMutableArray *)failedtkUrlWithArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error;

- (void)reportWithUploadArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
