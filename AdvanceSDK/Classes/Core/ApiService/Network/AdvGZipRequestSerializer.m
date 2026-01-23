//
//  AdvGZipRequestSerializer.m
//  MercurySDK
//
//  Created by guangyao on 2025/11/20.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import "AdvGZipRequestSerializer.h"
#import "NSData+Adv_GZIP.h"

@implementation AdvGZipRequestSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _compressionThreshold = 500;
    }
    return self;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError * _Nullable __autoreleasing *)error {
    
    NSMutableURLRequest *serializedRequest = [[super requestBySerializingRequest:request
                                                                  withParameters:parameters
                                                                           error:error] mutableCopy];
    if (!serializedRequest) {
        return nil;
    }
    
    if (parameters && serializedRequest.HTTPBody.length > self.compressionThreshold) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:error];
        NSData *compressedData = [jsonData adv_gzippedData];
        if (compressedData) {
            [serializedRequest setHTTPBody:compressedData];
            [serializedRequest setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        }
    }
    
    return serializedRequest;
}

@end
