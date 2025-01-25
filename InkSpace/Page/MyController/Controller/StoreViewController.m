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
    self.isStore = YES;
}

#pragma mark - BaseListViewController

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    NSArray *arr = [[StoreManager sharedManager] getAllModels];
    if (completion) {
        completion(arr);
        [self hideLoading];
    }
}

- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion {
    // 收藏页面不需要加载更多数据
    if (completion) {
        completion(@[]);
    }
}

- (void)configureCell:(HomeViewCell *)cell withModel:(HomeModel *)model {
    [super configureCell:cell withModel:model];
    cell.likeButton.hidden = YES;  // 在收藏页面隐藏喜欢按钮
}

@end

