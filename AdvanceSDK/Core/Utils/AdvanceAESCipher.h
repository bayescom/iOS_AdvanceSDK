//
//  AdvanceAESCipher.h
//  AdvanceSDK
//
//  Created by MS on 2022/5/5.
//  Copyright © 2022 Advance. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * advanceAesEncryptString(NSString *content, NSString *key);
NSString * advanceAesDecryptString(NSString *content, NSString *key);

NSData * advanceAesEncryptData(NSData *data, NSData *key);
NSData * advanceAesDecryptData(NSData *data, NSData *key);

@interface AdvanceAESCipher : NSObject
//将string转成带密码的data
+ (NSString*)encryptAESData:(NSString*)string Withkey:(NSString * )key ivkey:(NSString * )ivkey;
//将带密码的data转成string
+(NSString*)decryptAESData:(NSString*)data Withkey:(NSString *)key ivkey:(NSString * )ivkey;
@end
