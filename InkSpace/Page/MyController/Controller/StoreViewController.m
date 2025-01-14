//
//  StoreViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import "StoreViewController.h"
#import "StoreManager.h"
#import "HomeModel.h"
#import "DetailViewController.h"

@interface StoreViewController ()
@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收藏";
}

#pragma mark - BaseListViewController

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    NSArray *arr = [[StoreManager sharedManager] getAllModels];
    if (completion) {
        completion(arr);
    }
}

- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion {
    // 收藏页面不需要加载更多数据
    if (completion) {
        completion(@[]);
    }
}

#pragma mark - HomeViewCellDelegate

- (void)homeViewCell:(HomeViewCell *)cell didClickDownloadButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    NSString *picString = [NSString stringWithFormat:@"%s%@", base_pic, model.url];
    [self downloadImage:picString];
}

- (void)homeViewCell:(HomeViewCell *)cell didClickDeleteButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    [[StoreManager sharedManager] removeModelWithID:model.ID];
    [self.items removeObject:model];
    [self.tableView reloadData];
}

- (void)configureCell:(HomeViewCell *)cell withModel:(HomeModel *)model {
    [super configureCell:cell withModel:model];
    cell.likeButton.hidden = YES;  // 在收藏页面隐藏喜欢按钮
}

@end

