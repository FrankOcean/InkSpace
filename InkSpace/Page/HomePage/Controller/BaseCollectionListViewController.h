//
//  BaseCollectionListViewController.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//  通用列表功能（CollectionView版本）

#import "BaseCollectionViewController.h"
#import "HomeModel.h"
#import "HomeCollectionViewCell.h"
#import "URLFetcher.h"

@interface BaseCollectionListViewController : BaseCollectionViewController <HomeCollectionViewCellDelegate>

@property (nonatomic, strong) NSMutableArray <HomeModel *> *items;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) BOOL isStore;

// 子类需要重写的方法来实现具体的数据获取逻辑
- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion;
- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion;

// 通用的UI配置方法
- (void)configureRefreshControl;
- (void)configureCell:(HomeCollectionViewCell *)cell withModel:(HomeModel *)model;

// 图片下载相关方法
- (void)downloadImage:(NSString *)imageUrl;

@end 