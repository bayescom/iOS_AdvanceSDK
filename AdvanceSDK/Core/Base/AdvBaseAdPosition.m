//
//  AdvBaseAdPosition.m
//  AdvanceSDK
//
//  Created by MS on 2021/10/12.
//

#import "AdvBaseAdPosition.h"
#import "AdvLog.h"
#import "AdvSupplierModel.h"
@interface AdvBaseAdPosition ()
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation AdvBaseAdPosition

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _supplier = supplier;
    }
    return self;
}



- (void)loadAd {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        
        if (!_supplier) {
            return;
        }
            NSLog(@"基类load情况 %ld  %d %@ %@", _supplier.priority, _supplier.isParallel, _supplier,_supplier.sdktag );
        if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
                    NSLog(@"基类成功啦 %ld %d %@", _supplier.priority, _supplier.isParallel, _supplier.sdktag);
            [self supplierStateSuccess];
            
        } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
                    NSLog(@"基类失败啦 %ld %d %@", _supplier.priority, _supplier.isParallel, _supplier.sdktag);
            [self supplierStateFailed];
            
        } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
                    NSLog(@"基类请求中啦 %ld %d %@", _supplier.priority, _supplier.isParallel, _supplier.sdktag);
            [self supplierStateInPull];
            
        } else {
                    NSLog(@"基类请load %ld %d %@", _supplier.priority, _supplier.isParallel, _supplier.sdktag);
            [self supplierStateLoad];
        }
    });
    
}

- (void)supplierStateSuccess {
    
}
    
- (void)supplierStateFailed {
    
}

- (void)supplierStateInPull {
    
}

- (void)supplierStateLoad {
    
}





- (void)showAd {
    
}

- (void)deallocAdapter {
    
}

@end
