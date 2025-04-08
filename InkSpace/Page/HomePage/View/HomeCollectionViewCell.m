//
//  HomeCollectionViewCell.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    // 创建imgView
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleToFill;
    self.imgView.layer.cornerRadius = 10.0;
    self.imgView.clipsToBounds = YES;
    [self.contentView addSubview:self.imgView];
    
    // 创建backImgView，用于显示渐变背景
    self.backImgView = [[UIImageView alloc] init];
    self.backImgView.contentMode = UIViewContentModeScaleToFill;
    // 如果有渐变图片，使用：self.backImgView.image = [UIImage imageNamed:@"gradient_image.png"];
    [self.contentView addSubview:self.backImgView];
    
    // 创建下载按钮
    self.downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    self.downloadBtn.layer.borderColor = UIColorFromRGB(0x79a6e5).CGColor;
    self.downloadBtn.layer.cornerRadius = 10.0;
    self.downloadBtn.layer.borderWidth = 1.0;
    self.downloadBtn.tintColor = UIColorFromRGB(0x79a6e5);
    [self.downloadBtn addTarget:self action:@selector(downloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.downloadBtn];
    
    // 创建喜欢按钮
    self.likeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.likeButton setTitle:@"喜欢" forState:UIControlStateNormal];
    self.likeButton.layer.borderColor = UIColorFromRGB(0x79a6e5).CGColor;
    self.likeButton.layer.cornerRadius = 10.0;
    self.likeButton.layer.borderWidth = 1.0;
    self.likeButton.tintColor = UIColorFromRGB(0x79a6e5);
    [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.likeButton];
    
    // 创建删除按钮
    self.delButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.delButton setTitle:@"删除" forState:UIControlStateNormal];
    self.delButton.layer.borderColor = UIColorFromRGB(0x79a6e5).CGColor;
    self.delButton.layer.cornerRadius = 10.0;
    self.delButton.layer.borderWidth = 1.0;
    self.delButton.tintColor = UIColorFromRGB(0x79a6e5);
    [self.delButton addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.delButton];
    
    // 根据DEBUG环境控制删除按钮显示
#if DEBUG
    self.delButton.hidden = YES;
    self.likeButton.hidden = YES;
    self.downloadBtn.hidden = YES;
#else
    self.delButton.hidden = YES;
    self.likeButton.hidden = YES;
    self.downloadBtn.hidden = YES;
#endif
    
    // 设置约束
    [self setupConstraints];
    
    // 设置底部圆角
    [self setBottomCornersToRounded:self.backImgView withRadius:10.0];
}

- (void)setupConstraints {
    // 禁用自动约束
    self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backImgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.downloadBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.likeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.delButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // imgView约束
    [NSLayoutConstraint activateConstraints:@[
        [self.imgView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.imgView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.imgView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.imgView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0]
    ]];
    
    // backImgView约束
    [NSLayoutConstraint activateConstraints:@[
        [self.backImgView.leadingAnchor constraintEqualToAnchor:self.imgView.leadingAnchor],
        [self.backImgView.trailingAnchor constraintEqualToAnchor:self.imgView.trailingAnchor],
        [self.backImgView.bottomAnchor constraintEqualToAnchor:self.imgView.bottomAnchor],
        [self.backImgView.heightAnchor constraintEqualToConstant:40]
    ]];
    
    // 下载按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.downloadBtn.bottomAnchor constraintEqualToAnchor:self.imgView.bottomAnchor],
        [self.downloadBtn.trailingAnchor constraintEqualToAnchor:self.imgView.trailingAnchor],
        [self.downloadBtn.widthAnchor constraintEqualToAnchor:self.downloadBtn.heightAnchor multiplier:2.0]
    ]];
    
    // 删除按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.delButton.bottomAnchor constraintEqualToAnchor:self.imgView.bottomAnchor],
        [self.delButton.centerXAnchor constraintEqualToAnchor:self.imgView.centerXAnchor],
        [self.delButton.heightAnchor constraintEqualToAnchor:self.downloadBtn.heightAnchor multiplier:1.01942]
    ]];
    
    // 喜欢按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.likeButton.bottomAnchor constraintEqualToAnchor:self.imgView.bottomAnchor],
        [self.likeButton.leadingAnchor constraintEqualToAnchor:self.imgView.leadingAnchor]
    ]];
}

// 对 UIImageView 设置底部圆角的方法
- (void)setBottomCornersToRounded:(UIImageView *)imageView withRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, 40) byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = imageView.bounds;
    maskLayer.path = path.CGPath;
    imageView.layer.mask = maskLayer;
}

// 按钮事件处理
- (void)downloadButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeCollectionViewCellDidTapDownloadButton:)]) {
        [self.delegate homeCollectionViewCellDidTapDownloadButton:self];
    }
}

- (void)likeButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeCollectionViewCellDidTapDownLikeButton:)]) {
        [self.delegate homeCollectionViewCellDidTapDownLikeButton:self];
    }
}

- (void)delButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeCollectionViewCellDidTapDownDeleteButton:)]) {
        [self.delegate homeCollectionViewCellDidTapDownDeleteButton:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 因为maskLayer依赖于视图尺寸，所以在布局后重新设置底部圆角
    [self setBottomCornersToRounded:self.backImgView withRadius:10.0];
}

@end 
