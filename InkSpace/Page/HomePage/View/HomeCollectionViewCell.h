//
//  HomeCollectionViewCell.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HomeCollectionViewCellDelegate;

@interface HomeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIImageView *backImgView;

@property (nonatomic, strong) UIButton *downloadBtn;

@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, strong) UIButton *delButton;

@property (weak, nonatomic) id <HomeCollectionViewCellDelegate> delegate;

@end


@protocol HomeCollectionViewCellDelegate <NSObject>

@optional
- (void)homeCollectionViewCellDidTapDownloadButton:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidTapDownLikeButton:(HomeCollectionViewCell *)cell;
- (void)homeCollectionViewCellDidTapDownDeleteButton:(HomeCollectionViewCell *)cell;

@end

NS_ASSUME_NONNULL_END 