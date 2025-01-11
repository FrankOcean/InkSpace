//
//  BaseListViewController.h
//  InkSpace
//
//  Created by puyang on 2025/1/10.
//  通用列表功能

#import "BaseTableViewController.h"
#import "HomeModel.h"
#import "HomeViewCell.h"
#import "URLFetcher.h"

@interface BaseListViewController : BaseTableViewController <HomeViewCellDelegate>

@property (nonatomic, strong) NSMutableArray <HomeModel *> *items;
@property (nonatomic, assign) NSUInteger currentPage;

// 子类需要重写的方法来实现具体的数据获取逻辑
- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion;
- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion;

// 通用的UI配置方法
- (void)configureRefreshControl;
- (void)configureCell:(HomeViewCell *)cell withModel:(HomeModel *)model;
- (CGFloat)calculateCellHeight:(HomeModel *)model;

@end
