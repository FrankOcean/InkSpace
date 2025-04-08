//
//  HistoryCollectionViewController.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//
#import "HistoryCollectionViewController.h"
#import "HomeModel.h"
#import "URLFetcher.h"
#import "DetailViewController.h"
#import "StoreManager.h"

@interface HistoryCollectionViewController ()
@end

@implementation HistoryCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史记录";
    self.history_id = [HomeModel getHistoricIDForCategory:self.category];
}

#pragma mark - BaseCollectionListViewController

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
    if (![scrollView isKindOfClass:[UICollectionView class]]) {
        return;
    }
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSArray *visibleIndexPaths = [collectionView indexPathsForVisibleItems];
    if (!visibleIndexPaths.count || !self.items.count) {
        return;
    }
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        if (indexPath.item >= self.items.count) {
            continue;
        }
        HomeModel *model = self.items[indexPath.item];
        if(model.ID >= self.history_id) {
            [HomeModel setHistoricID:model.ID forCategory:self.category];
        }
    }
}

@end 