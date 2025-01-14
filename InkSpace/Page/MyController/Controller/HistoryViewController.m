//
//  HistoryViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//
#import "HistoryViewController.h"
#import "HomeModel.h"
#import "URLFetcher.h"
#import "DetailViewController.h"
#import "StoreManager.h"

@interface HistoryViewController ()
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史记录";
    self.history_id = [HomeModel getHistoricIDForCategory:self.category];
}

#pragma mark - BaseListViewController

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    self.currentPage = [HomeModel getHistoricIDForCategory:self.category];
    [[URLFetcher sharedInstance] fetchURLsWithCategory:self.category andCurrentId:self.currentPage andCompletion:^(NSArray * _Nonnull fetchedArray) {
        HomeModel *model = [fetchedArray lastObject];
        self.currentPage = model.ID;
        if (completion) {
            completion(fetchedArray);
        }
    }];
}

- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion {
    [[URLFetcher sharedInstance] fetchURLsWithCategory:self.category andCurrentId:self.currentPage andCompletion:^(NSArray * _Nonnull fetchedArray) {
        HomeModel *model = [fetchedArray lastObject];
        self.currentPage = model.ID;
        if (completion) {
            completion(fetchedArray);
        }
    }];
}

#pragma mark - HomeViewCellDelegate

- (void)homeViewCell:(HomeViewCell *)cell didClickDownloadButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    NSString *picString = [NSString stringWithFormat:@"%s%@", base_pic, model.url];
    [super downloadImage:picString];
}

- (void)homeViewCell:(HomeViewCell *)cell didClickDeleteButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    [[URLFetcher sharedInstance] fetchDeleteURLsWithID:model.ID];
    [self.items removeObject:model];
    [self.tableView reloadData];
}

- (void)homeViewCell:(HomeViewCell *)cell didClickLikeButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    model.favorite += 1;
    [[URLFetcher sharedInstance] fetchLikeCount:model.favorite andID:model.ID];
    [[StoreManager sharedManager] addModel:model];
    [self.items replaceObjectAtIndex:indexPath.row withObject:model];
    [self.tableView reloadData];
}

@end
