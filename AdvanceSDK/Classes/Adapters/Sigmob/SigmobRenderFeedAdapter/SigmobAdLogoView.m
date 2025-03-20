//
//  SigmobAdLogoView.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "SigmobAdLogoView.h"
#import "AdvanceAsset.h"

@interface SigmobAdLogoView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *logoTextLabel;

@end

@implementation SigmobAdLogoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
    self.layer.cornerRadius = 2;
    [self addSubview:self.logoImageView];
    [self addSubview:self.logoTextLabel];
}

- (void)layoutSubviews {
    self.logoImageView.frame = CGRectMake(3, 2, 12, 12);
    self.logoTextLabel.frame = CGRectMake(19, 2, 21, 12);
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.image = [AdvanceAsset bundleImageNamed:@"sigmob_ad_logo"];
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
