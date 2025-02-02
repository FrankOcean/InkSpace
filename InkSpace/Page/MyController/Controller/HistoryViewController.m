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
            [self hideLoading];
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    
    UITableView *tableView = (UITableView *)scrollView;
    NSArray *visibleIndexPaths = [tableView indexPathsForVisibleRows];
    if (!visibleIndexPaths.count || !self.items.count) {
        return;
    }
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        if (indexPath.row >= self.items.count) {
            continue;
        }
        HomeModel *model = self.items[indexPath.row];
        if(model.ID >= self.history_id) {
            [HomeModel setHistoricID:model.ID forCategory:self.category];
        }
    }
}

@end
