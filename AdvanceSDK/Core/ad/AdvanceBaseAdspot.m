//
//  AdvanceBaseAdspot.m
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "AdvanceBaseAdspot.h"

#import <AdSupport/AdSupport.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "AdvanceDeviceInfoUtil.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceLog.h"

// MARK: ======================= Error Code & Msg =======================
static int const AdvanceErrorCode_NoMoreSupplier = 10301;
static int const AdvanceErrorCode_Server_01 = 10501;
static int const AdvanceErrorCode_Server_02 = 10502;
static int const AdvanceErrorCode_JsonParse_01 = 10502;

static NSString *const AdvanceErrorMsg_NoMoreSupplier = @"无策略";
static NSString *const AdvanceErrorMsg_Server_01 = @"策略服务器出错";
static NSString *const AdvanceErrorMsg_Server_02 = @"服务器连接出错";
static NSString *const AdvanceErrorMsg_JsonParse_01 = @"策略Json解析出错";

#define AdvanceError(errCode, msg) [NSError errorWithDomain:@"com.AdvanceSDK.error" code:errCode userInfo:@{@"msg":msg}]

/// 以字符串形式返回状态码
NSString * ADVStringFromNAdvanceSdkSupplierRepoType(AdvanceSdkSupplierRepoType type) {
    switch (type) {
        case AdvanceSdkSupplierRepoLoaded:
            return @"AdvanceSdkSupplierRepoLoaded(发起加载请求上报)";
        case AdvanceSdkSupplierRepoClicked:
            return @"AdvanceSdkSupplierRepoClicked(点击上报)";
        case AdvanceSdkSupplierRepoSucceeded:
            return @"AdvanceSdkSupplierRepoSucceeded(数据加载成功上报)";
        case AdvanceSdkSupplierRepoImped:
            return @"AdvanceSdkSupplierRepoImped(曝光上报)";
        case AdvanceSdkSupplierRepoFaileded:
            return @"AdvanceSdkSupplierRepoFaileded(失败上报)";
        default:
            return @"MercuryBaseAdRepoTKEventTypeUnknow(未知类型上报)";
    }
}

@interface AdvanceBaseAdspot ()
@property (nonatomic, strong) SdkSupplier *defaultSdkSupplier;
@property(nonatomic, strong) id splashAd;

@end

@implementation AdvanceBaseAdspot
NSString *const CACHE_PREFIX = @"mercury_advance_%@";

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid {
    if (self = [super init]) {
        _adspotid = adspotid;
        _mediaid = mediaid;
        _defaultSdkSupplier = nil;
        _currentSdkSupplier = nil;
        _suppliers = nil;
        _enableStrategyCache = YES;
    }
    return self;
}

- (void)loadAd {
    @try {
        [self.suppliers removeAllObjects];
        self.currentSdkSupplier = nil;
        if (!self.defaultSdkSupplier) {
            NSLog(@"请设置打底渠道 (setDefaultSdkSupplierWithMediaId:adspotid:mediakey:sdkId)");
            return;
        }
        if (self.enableStrategyCache) {
//            //从缓存读取策略
            [self loadStrategyFromCache];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [NSThread sleepForTimeInterval:0.2];
                [self loadStrategyFromServerToCache:YES];
            });
        } else {
            //直接获取策略
            [self loadStrategyFromServerToCache:NO];
        }
    } @catch (NSException *exception) {
        [self processRequestFailed];
    } @finally {
    }
}

// MARK: ======================= repo =======================
/// 上报
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType {
    NSArray<NSString *> *uploadArr = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadArr = self.currentSdkSupplier.loadedtk;
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadArr =  self.currentSdkSupplier.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceeded) {
        uploadArr =  self.currentSdkSupplier.succeedtk;
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadArr =  self.currentSdkSupplier.imptk;
    } else if (repoType == AdvanceSdkSupplierRepoFaileded) {
        uploadArr =  self.currentSdkSupplier.failedtk;
    }
    if (!uploadArr || uploadArr.count <= 0) {
        // TODO: 上报地址不存在，如何处理忽略还是回调错误
    }
    for (id obj in uploadArr) {
        @try {
            NSString *urlString = obj;
            NSTimeInterval timeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
            urlString = [urlString stringByReplacingOccurrencesOfString:@"__TIME__" withString:[NSString stringWithFormat:@"%0.0f", timeStamp]];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:
                                            NSURLRequestReloadIgnoringLocalCacheData   timeoutInterval:5];
            request.HTTPMethod = @"GET";
            NSURLSession *sharedSession = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                              completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                if (error == nil) {
                  
                } else {
                  
                }
            }];
            [dataTask resume];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
//    NSLog(@"%@ = 上报(impid: %@)", ADVStringFromNAdvanceSdkSupplierRepoType(repoType), self.currentSdkSupplier.name);
}

// MARK: ======================= Data Fetch & Store =======================
- (void)loadStrategyFromCache {
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSObject *object = [userDefaults objectForKey:[NSString stringWithFormat:CACHE_PREFIX, self.adspotid]];
        if (object) {
            NSDictionary *dict = (NSDictionary *) object;
            [self processRequestResult:dict];
        } else {
            [self processRequestFailed];
        }
    } @catch (NSException *exception) {
        [self processRequestFailed];
    } @finally {
    }
}

- (void)loadStrategyFromServerToCache:(BOOL)isToCache {
    @try {
        NSMutableDictionary *deviceInfo = [AdvanceDeviceInfoUtil getDeviceInfoWithMediaId:self.mediaid adspotId:self.adspotid];
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
        NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:
                NSURLRequestReloadIgnoringLocalCacheData   timeoutInterval:5];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody = jsonData;
        request.HTTPMethod = @"POST";
        //use share session
        NSURLSession *sharedSession = [NSURLSession sharedSession];
        //use system dataTask
        NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                          completionHandler:
                                                                  ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                      if (data && (error == nil)) {
                                                                          NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
                                                                          if (httpResp.statusCode != 200) {
                                                                              AdvanceLog(AdvanceErrorMsg_Server_01);
                                                                              [self selectSdkSupplierFailed:AdvanceError(AdvanceErrorCode_Server_01, AdvanceErrorMsg_Server_01)];
                                                                              if (!isToCache) {
                                                                                  [self processRequestFailed];
                                                                              }

                                                                          } else {
                                                                              NSError *jsonError;
                                                                              //parse json data
                                                                              NSDictionary *repJsonDict =
                                                                                      [NSJSONSerialization JSONObjectWithData:data
                                                                                                                      options:NSJSONReadingAllowFragments
                                                                                                                        error:&jsonError];
                                                                              if (jsonError) {
                                                                                  AdvanceLog(AdvanceErrorMsg_JsonParse_01);
                                                                                  [self selectSdkSupplierFailed:AdvanceError(AdvanceErrorCode_JsonParse_01, AdvanceErrorMsg_JsonParse_01)];
                                                                                  if (!isToCache) {
                                                                                      [self processRequestFailed];
                                                                                  }
                                                                              } else {
                                                                                  if ([[repJsonDict objectForKey:@"code"] isEqual:@200]) {
                                                                                      if (!isToCache) {
                                                                                          [self processRequestResult:repJsonDict];
                                                                                      } else {
                                                                                          //仅仅保存至缓存
                                                                                          NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                                                                                          [userDefault setObject:repJsonDict forKey:[NSString stringWithFormat:CACHE_PREFIX, self.adspotid]];
                                                                                          [userDefault synchronize];
                                                                                      }
                                                                                  } else {
                                                                                      AdvanceLog(AdvanceErrorMsg_Server_01);
                                                                                      [self selectSdkSupplierFailed:AdvanceError(AdvanceErrorCode_Server_01, AdvanceErrorMsg_Server_01)];
                                                                                      if (!isToCache) {
                                                                                          [self processRequestFailed];
                                                                                      }

                                                                                  }
                                                                              }
                                                                          }
                                                                      } else {
                                                                          AdvanceLog(AdvanceErrorMsg_Server_02);
                                                                          [self selectSdkSupplierFailed:AdvanceError(AdvanceErrorCode_Server_02, AdvanceErrorMsg_Server_02)];
                                                                          if (!isToCache) {
                                                                              [self processRequestFailed];
                                                                          }
                                                                      }
                                                                  }];
        //task need to resume
        [dataTask resume];
    } @catch (NSException *exception) {
        if (!isToCache) {
            [self processRequestFailed];
        }
    } @finally {
    }
}

// MARK: ======================= 构建打底渠道 =======================
- (void)setDefaultSdkSupplierWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotid mediaKey:(NSString *)mediakey sdkId:(nonnull NSString *)sdkid {
    self.defaultSdkSupplier = [[SdkSupplier alloc] initWithMediaId:mediaId adspotId:adspotid mediaKey:mediakey sdkId:sdkid];
}

- (NSString *)constructDefaultTk:(NSString *)url withAppId:(NSString *)appid adspotId:(NSString *)adspotid idfa:(NSString *)idfa
                      supplierId:(NSString *)supplierid auctionId:(NSString*)auctionId supplierAdspotId:(NSString*) supplierAdspotId{
    @try {
        NSString *url2 = [url stringByReplacingOccurrencesOfString:@"__ADSPOTID__" withString:self.adspotid];
        NSString *url3 = [url2 stringByReplacingOccurrencesOfString:@"__APPID__" withString:self.mediaid];
        NSString *url4 = [url3 stringByReplacingOccurrencesOfString:@"__IDFA__" withString:idfa];
        NSString *url5 = [url4 stringByReplacingOccurrencesOfString:@"__SUPPLIERID__" withString:supplierid];
        NSString *url6 = [url5 stringByReplacingOccurrencesOfString:@"__AUCTION_ID__" withString:auctionId];
        NSString *url7 = [url6 stringByReplacingOccurrencesOfString:@"__SUPPLIER_ADSPOT_ID__" withString:supplierAdspotId];
        return url7;
    }
    @catch (NSException *e) {
        return url;
    }
}

- (void)processRequestFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            if (self.defaultSdkSupplier) {
                [self addDefaultSdkSupplierTK];
                self.suppliers = [[NSMutableArray alloc] init];
                [self.suppliers addObject:self.defaultSdkSupplier];
                [self selectSdkSupplier];
            } else {
                [self selectSdkSupplierFailed:AdvanceError(AdvanceErrorCode_Server_01, AdvanceErrorMsg_Server_01)];
            }
        } @catch (NSException *exception) {
        } @finally {
        }
    });
}

- (void)processRequestResult:(NSDictionary *)resultDict {
    @try {
        self.suppliers = [[NSMutableArray alloc] init];
        NSArray *supplierArray = [resultDict objectForKey:@"suppliers"];
        if (supplierArray) {
            for (NSDictionary *supplierDict in supplierArray) {
                SdkSupplier *supplier = [[SdkSupplier alloc]
                        initWithMediaId:[supplierDict objectForKey:@"mediaid"]
                               adspotId:[supplierDict objectForKey:@"adspotid"]
                               mediaKey:[supplierDict objectForKey:@"mediakey"]
                                 sdkId:[supplierDict objectForKey:@"id"]];
                supplier.sdkTag = [supplierDict objectForKey:@"sdktag"];
                supplier.timeout = [[supplierDict objectForKey:@"timeout"] intValue];
                supplier.priority = [[supplierDict objectForKey:@"priority"] intValue];
                supplier.name = [supplierDict objectForKey:@"name"];
                if ([supplierDict objectForKey:@"adcount"]) {
                    supplier.adCount = [[supplierDict objectForKey:@"adcount"] intValue];
                }
                supplier.succeedtk = [supplierDict objectForKey:@"succeedtk"];
                supplier.failedtk = [supplierDict objectForKey:@"failedtk"];
                supplier.imptk = [supplierDict objectForKey:@"imptk"];
                supplier.clicktk = [supplierDict objectForKey:@"clicktk"];
                supplier.loadedtk =[supplierDict objectForKey:@"loadedtk"];
                [self.suppliers addObject:supplier];
            }
            //按照priority排序
            [SdkSupplier sortByPriority:self.suppliers];
            [self selectSdkSupplier];
        }
    } @catch (NSException *exception) {
    }
}

- (NSString *)getIdfa {
    @try {
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return idfa == nil ? @"" : idfa;
    } @catch (NSException *exception) {
        return @"";
    }
}

- (NSString *)getAuctionId {
    @try {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        return [[uuid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    } @catch (NSException *exception) {
        return @"";
    }
}

- (void)selectSdkSupplier {
    [self selectSdkSupplierWithError:nil];
}

- (void)selectSdkSupplierWithError:(NSError * _Nullable)error {
    if (self.suppliers == nil ||
       [self.suppliers count] == 0) {
        [self selectSdkSupplierFailed:AdvanceError(AdvanceErrorCode_NoMoreSupplier, AdvanceErrorMsg_NoMoreSupplier)];
    } else {
        @try {
            self.currentSdkSupplier = self.suppliers.firstObject;
            [self.suppliers removeObjectAtIndex:0];
            [self reportWithType:AdvanceSdkSupplierRepoLoaded];
            if ([_supplierDelegate respondsToSelector:@selector(advanceBaseAdspotWithSdkId:params:)]) {
                [_supplierDelegate advanceBaseAdspotWithSdkId:self.currentSdkSupplier.id params:@{
                    @"mediaid": self.currentSdkSupplier.mediaid,
                    @"adspotid": self.currentSdkSupplier.adspotid,
                    @"mediakey": self.currentSdkSupplier.mediakey,
                }];
            }
        } @catch (NSException *exception) {
            [self selectSdkSupplier];
        }
    }
}

-(void)addDefaultSdkSupplierTK{
    if (self.defaultSdkSupplier) {
        @try {
            NSString *idfa = [self getIdfa];
            NSString *auctionId= [self getAuctionId];
            self.defaultSdkSupplier.imptk = [[[NSMutableArray alloc] init] arrayByAddingObject:
                                             [self constructDefaultTk:DEFAULT_IMPTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.defaultSdkSupplier.id auctionId:auctionId supplierAdspotId:self.defaultSdkSupplier.adspotid]];
            self.defaultSdkSupplier.succeedtk = [[[NSMutableArray alloc] init] arrayByAddingObject:
                                                 [self constructDefaultTk:DEFAULT_SUCCEEDTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.defaultSdkSupplier.id auctionId:auctionId supplierAdspotId:self.defaultSdkSupplier.adspotid]];
            self.defaultSdkSupplier.clicktk = [[[NSMutableArray alloc] init] arrayByAddingObject:
                                               [self constructDefaultTk:DEFAULT_CLICKTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.defaultSdkSupplier.id auctionId: auctionId supplierAdspotId:self.defaultSdkSupplier.adspotid]];
            self.defaultSdkSupplier.failedtk = [[[NSMutableArray alloc] init] arrayByAddingObject:
                                                [self constructDefaultTk:DEFAULT_FAILEDTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.defaultSdkSupplier.id auctionId:auctionId supplierAdspotId:self.defaultSdkSupplier.adspotid]];
            self.defaultSdkSupplier.loadedtk =[[[NSMutableArray alloc] init] arrayByAddingObject:
                                               [self constructDefaultTk:DEFAULT_LOADEDTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.defaultSdkSupplier.id auctionId:auctionId supplierAdspotId:self.defaultSdkSupplier.adspotid]];
        } @catch (NSException *exception) {
        }
    }
}

- (void)selectSdkSupplierFailed:(NSError *)error {
    if ([_supplierDelegate respondsToSelector:@selector(advanceBaseAdspotWithSdkId:error:)]) {
        [_supplierDelegate advanceBaseAdspotWithSdkId:self.currentSdkSupplier.id error:error];
    }
}
@end
