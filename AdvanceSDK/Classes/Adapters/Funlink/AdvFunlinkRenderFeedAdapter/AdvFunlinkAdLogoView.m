//
//  AdvFunlinkAdLogoView.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkAdLogoView.h"

@interface AdvFunlinkAdLogoView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *logoTextLabel;
@property (nonatomic, strong) UIImage *logoImage;

@end

@implementation AdvFunlinkAdLogoView

- (instancetype)initWithAdLogo:(UIImage *)logo {
    if (self = [super init]) {
        self.logoImage = logo;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
    self.layer.cornerRadius = 2;
    [self addSubview:self.logoImageView];
//    [self addSubview:self.logoTextLabel];
}

- (void)layoutSubviews {
//    self.logoImageView.frame = CGRectMake(3, 2, 12, 12);
//    self.logoTextLabel.frame = CGRectMake(19, 2, 21, 12);
    self.logoImageView.frame = CGRectMake(0, 0, 43, 16);
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.image = self.logoImage;
    }
    return _logoImageView;
}

-(UILabel *)logoTextLabel {
    if (!_logoTextLabel) {
        _logoTextLabel = [[UILabel alloc] init];
        _logoTextLabel.font = [UIFont systemFontOfSize:10];
        _logoTextLabel.textColor = UIColor.whiteColor;
        _logoTextLabel.textAlignment = NSTextAlignmentCenter;
        _logoTextLabel.text = @"广告";
    }
    return _logoTextLabel;
}

@end
