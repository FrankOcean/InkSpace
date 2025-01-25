//
//  ViewController.m
//  InkSpace
//
//  Created by puyang on 2024/6/14.
//

#import "ViewController.h"
#import "URLFetcher.h"

@implementation ViewController

- (instancetype)initWithCategory:(NSUInteger)category {
    self = [super init];
    if (self) {
        _category = category;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.history_id = [HomeModel getHistoricIDForCategory:self.category];
}

#pragma mark - BaseListViewController

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    self.currentPage = 1;
    [[URLFetcher sharedInstance] fetchURLsWithCategory:self.category andCompletion:^(NSArray * _Nonnull fetchedArray) {
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

