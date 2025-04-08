//
//  HomeViewCell.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HomeViewCellDelegate;

@interface HomeViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UIImageView *backImgView;

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (weak, nonatomic) IBOutlet UIButton *delButton;

@property (weak, nonatomic) id <HomeViewCellDelegate> delegate;

@end


@protocol HomeViewCellDelegate <NSObject>

@optional
- (void)homeViewCellDidTapDownloadButton:(HomeViewCell *)cell;
- (void)homeViewCellDidTapDownLikeButton:(HomeViewCell *)cell;
- (void)homeViewCellDidTapDownDeleteButton:(HomeViewCell *)cell;

@end

NS_ASSUME_NONNULL_END
