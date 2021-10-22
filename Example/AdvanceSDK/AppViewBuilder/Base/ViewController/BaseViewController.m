//
//  BaseViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewBuilder.h"

@interface BaseViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *_v1;
@property (nonatomic, strong) UIView *_v2;
@property (nonatomic, strong) UIView *_v3;
@property (nonatomic, strong) UIView *_cusV;
@property (nonatomic, strong) UILabel *adShowView;

@property (nonatomic, strong) UILabel *_lbl01;
@property (nonatomic, strong) UITextField *_txtF01;
@property (nonatomic, strong) UILabel *_lbl02;
@property (nonatomic, strong) UITextField *_txtF02;

@property (nonatomic, strong) UIButton *_btn01;
@property (nonatomic, strong) UIButton *_btn02;
@property (nonatomic, strong) UITableView *_tableView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏键盘" style:UIBarButtonItemStylePlain target:__txtF01 action:@selector(resignFirstResponder)];
    self.navigationItem.rightBarButtonItem = settingItem;
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    }


}


- (BOOL)checkAdspotId {
    if (__txtF01.text.length > 0) {
        return YES;
    }
    [JDStatusBarNotification showWithStatus:@"请填写或选择广告Id" dismissAfter:1.5];
    return NO;
}

- (void)setInitDefSubviewsFlag:(BOOL)initDefSubviewsFlag {
    _initDefSubviewsFlag = initDefSubviewsFlag;
    if (_initDefSubviewsFlag) {
        [self.view addSubview:self._v1];
        [self.view addSubview:self._v2];
        [self.view addSubview:self._v3];
        [self.view addSubview:self.adShowView];
        __lbl01.text = @"MediaId";
        __lbl02.text = @"AdspotId";
        
        self._v1.frame = CGRectMake(0, 0, self.view.bounds.size.width*0.5, 200);
        self._v2.frame = CGRectMake(self.view.bounds.size.width*0.5, 0, self.view.bounds.size.width*0.5, 200);
        self._v3.frame = CGRectMake(0, CGRectGetMaxY(self._v2.frame), self.view.bounds.size.width, 1);
        _adShowView.frame = CGRectMake(0, CGRectGetMaxY(self._v3.frame)+118, self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(self._v3.frame)-118);
        
        __lbl01.frame = CGRectMake(0, 0, 60, 40);
        __txtF01.frame = CGRectMake(CGRectGetMaxX(self._lbl01.frame), 0,
                                    __v1.frame.size.width-CGRectGetMaxX(self._lbl01.frame),
                                    __lbl01.bounds.size.height);
        __lbl02.frame = CGRectMake(0, CGRectGetMaxY(__lbl01.frame), 60, 40);
        __txtF02.frame = CGRectMake(CGRectGetMaxX(self._lbl02.frame),
                                    CGRectGetMaxY(self._lbl01.frame),
                                    __v1.frame.size.width-CGRectGetMaxX(self._lbl02.frame),
                                    __lbl02.bounds.size.height);
        __cusV.frame = CGRectMake(0, CGRectGetMaxY(self._txtF02.frame),
                                  __v1.bounds.size.width,
                                  __v1.bounds.size.height-CGRectGetMaxY(self._txtF02.frame));
        __tableView.frame = __v2.bounds;
    } else {
        [__v1 removeConstraints:__v1.constraints];
        [__v2 removeConstraints:__v2.constraints];
        [__v3 removeConstraints:__v3.constraints];
        [__v1 removeFromSuperview];
        [__v2 removeFromSuperview];
        [__v3 removeFromSuperview];
    }
}

// MARK: ======================= Action =======================
- (void)loadAdBtn1Action {}
- (void)loadAdBtn2Action {}

// MARK: ======================= UITableViewDataSource, UITableViewDelegate =======================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _adspotIdsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell_def"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell_def"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = _adspotIdsArr[indexPath.row][@"addesc"];
    cell.detailTextLabel.text = _adspotIdsArr[indexPath.row][@"adspotId"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __txtF01.text = [self getTargetStr:_adspotIdsArr[indexPath.row][@"adspotId"]].firstObject;
    __txtF02.text = [self getTargetStr:_adspotIdsArr[indexPath.row][@"adspotId"]].lastObject;
}

- (NSArray *)getTargetStr:(NSString *)str {
    if (!str || str.length < 0 || ![str containsString:@"-"]) return @[str];
    return [str componentsSeparatedByString:@"-"];
}

// MARK: ======================= set =======================
- (void)setAdspotIdsArr:(NSArray<NSDictionary<NSString *,NSString *> *> *)adspotIdsArr {
    if (!_initDefSubviewsFlag) { self.initDefSubviewsFlag = YES; }
    _adspotIdsArr = adspotIdsArr;
    [__tableView reloadData];
}

- (void)setBtn1Title:(NSString *)btn1Title {
    if (!__btn01) {
        [self.view addSubview:self._btn01];
        self._btn01.frame = CGRectMake(10, CGRectGetMaxY(self._v3.frame)+6, self.view.bounds.size.width-20, 50);
    }
    _btn1Title = btn1Title;
    [__btn01 setTitle:btn1Title forState:UIControlStateNormal];
}

- (void)setBtn2Title:(NSString *)btn2Title {
    if (!__btn02) {
        [self.view addSubview:self._btn02];
        self._btn02.frame = CGRectMake(10, CGRectGetMaxY(self._btn01.frame)+6, self.view.bounds.size.width-20, 50);
    }
    _btn2Title = btn2Title;
    [__btn02 setTitle:btn2Title forState:UIControlStateNormal];
}

// MARK: ======================= get =======================
- (NSString *)mediaId {
    return __txtF01.text;
}

- (NSString *)adspotId {
    return __txtF02.text;
}

- (NSDictionary *)ext {
    return @{@"test" : @"自定义拓展参数"};
}

- (UIView *)cusView {
    return __cusV;
}

- (UILabel *)adShowView {
//    _adShowView.hidden = _adShowView.subviews.count <= 0;
    if (_adShowView) { return _adShowView; }
    _adShowView = [[UILabel alloc] initWithFrame:CGRectZero];
    _adShowView.text = @"广告展示区";
    _adShowView.userInteractionEnabled = YES;
    _adShowView.font = [UIFont systemFontOfSize:30];
    _adShowView.textColor = [UIColor whiteColor];
    _adShowView.backgroundColor = [UIColor colorWithRed:0.49 green:0.49 blue:0.53 alpha:1.00];
    _adShowView.textAlignment = NSTextAlignmentCenter;
    _adShowView.hidden = YES;
    _adShowView.userInteractionEnabled = YES;
    return _adShowView;
}

- (UIView *)_v1 {
    if (__v1) { return __v1; }
    __v1 = [ViewBuilder buildView];
    [__v1 addSubview:self._lbl01];
    [__v1 addSubview:self._txtF01];
    [__v1 addSubview:self._lbl02];
    [__v1 addSubview:self._txtF02];
    [__v1 addSubview:self._cusV];
    return __v1;
}

- (UIView *)_v2 {
    if (__v2) { return __v2; }
    __v2 = [ViewBuilder buildView];
    [__v2 addSubview:self._tableView];
    return __v2;
}

- (UITableView *)_tableView {
    if (!__tableView) {
        __tableView = [ViewBuilder buildTableView];
        __tableView.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.90 alpha:1.00];
        __tableView.delegate = self;
        __tableView.dataSource = self;
    }
    return __tableView;
}

- (UIView *)_cusV {
    if (__cusV) { return __cusV; }
    __cusV = [ViewBuilder buildView];
    __cusV.backgroundColor = [UIColor colorWithRed:0.56 green:0.77 blue:0.96 alpha:1.00];
    return __cusV;
}

- (UIView *)_v3 {
    if (__v3) { return __v3; }
    __v3 = [ViewBuilder buildView];
    __v3.backgroundColor = [UIColor colorWithRed:0.56 green:0.77 blue:0.96 alpha:1.00];
    return __v3;
}

- (UILabel *)_lbl01 {
    if (!__lbl01) {
        __lbl01 = [ViewBuilder buildLbl01];
    }
    return __lbl01;
}

- (UITextField *)_txtF01 {
    if (!__txtF01) {
        __txtF01 = [ViewBuilder buildTxt01];
    }
    return __txtF01;
}

- (UILabel *)_lbl02 {
    if (!__lbl02) {
        __lbl02 = [ViewBuilder buildLbl01];
    }
    return __lbl02;
}

- (UITextField *)_txtF02 {
    if (!__txtF02) {
        __txtF02 = [ViewBuilder buildTxt01];
    }
    return __txtF02;
}

- (UIButton *)_btn01 {
    if (!__btn01) {
        __btn01 = [UIButton buttonWithType:UIButtonTypeCustom];
        __btn01.backgroundColor = [UIColor colorWithRed:0.58 green:0.78 blue:0.42 alpha:1.00];
        [__btn01 addTarget:self action:@selector(loadAdBtn1Action) forControlEvents:UIControlEventTouchUpInside];
        __btn01.layer.cornerRadius = 25;
    }
    return __btn01;
}

- (UIButton *)_btn02 {
    if (!__btn02) {
        __btn02 = [UIButton buttonWithType:UIButtonTypeCustom];
        __btn02.backgroundColor = [UIColor colorWithRed:0.29 green:0.59 blue:1.00 alpha:1.00];
        [__btn02 addTarget:self action:@selector(loadAdBtn2Action) forControlEvents:UIControlEventTouchUpInside];
        __btn02.layer.cornerRadius = 25;
    }
    return __btn02;
}

@end
