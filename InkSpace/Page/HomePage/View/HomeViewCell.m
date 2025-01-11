//
//  HomeViewCell.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "HomeViewCell.h"

@implementation HomeViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置imgView的圆角
    self.imgView.layer.cornerRadius = 10.0;
    self.imgView.clipsToBounds = YES; 
    // 禁用选中时的背景色变化
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.imgView.contentMode = UIViewContentModeScaleToFill;
    
    self.downloadBtn.layer.borderColor = UIColorFromRGB(0x79a6e5).CGColor;
    self.likeButton.layer.borderColor = UIColorFromRGB(0x79a6e5).CGColor;
    self.delButton.layer.borderColor = UIColorFromRGB(0x79a6e5).CGColor;
    self.downloadBtn.layer.cornerRadius = 10.0;
    self.likeButton.layer.cornerRadius = 10.0;
    self.delButton.layer.cornerRadius = 10.0;
    self.downloadBtn.layer.borderWidth = 1.0;
    self.likeButton.layer.borderWidth = 1.0;
    self.delButton.layer.borderWidth = 1.0;

    [self.downloadBtn addTarget:self action:@selector(downloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.delButton addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self setBottomCornersToRounded:self.backImgView withRadius:10.0];
    

#if DEBUG
    self.delButton.hidden = YES;
#else
    self.delButton.hidden = NO;
#endif
    
}

// 对 UIImageView 设置底部圆角的方法
- (void)setBottomCornersToRounded:(UIImageView *)imageView withRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, 40) byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = imageView.bounds;
    maskLayer.path = path.CGPath;
    imageView.layer.mask = maskLayer;
}

- (void)downloadButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeViewCellDidTapDownloadButton:)]) {
        [self.delegate homeViewCellDidTapDownloadButton:self];
    }
}

- (void)likeButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeViewCellDidTapDownLikeButton:)]) {
        [self.delegate homeViewCellDidTapDownLikeButton:self];
    }
}

- (void)delButtonTapped {
    if ([self.delegate respondsToSelector:@selector(homeViewCellDidTapDownDeleteButton:)]) {
        [self.delegate homeViewCellDidTapDownDeleteButton:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
