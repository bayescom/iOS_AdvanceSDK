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

@end
