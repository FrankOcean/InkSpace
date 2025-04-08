//
//  BaseCollectionListViewController.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "BaseCollectionListViewController.h"
#import "DetailViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import <Photos/Photos.h>
#import "StoreManager.h"
#import "WaterfallFlowLayout.h"

#define golden_ratio 0.618

@implementation BaseCollectionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray array];
    self.currentPage = 0;
    [self configureRefreshControl];
    [self loadInitialData];
    
    // 设置导航栏和视图的背景色
    self.view.backgroundColor = [UIColor whiteColor];
    // 配置导航栏外观
    [self configureNavigationBar];
    
    // 设置collectionView的背景色
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)configureNavigationBar {
    // 子类可根据需要重写
}

- (void)configureRefreshControl {
    // 配置下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadInitialData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.collectionView.mj_header = header;
    
    // 配置上拉加载更多
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.collectionView.mj_footer = footer;
}

- (void)loadInitialData {
    [self fetchInitialData:^(NSArray *fetchedArray) {
        self.items = [NSMutableArray arrayWithArray:fetchedArray];
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
        
        // 如果没有数据，显示无数据的footer
        if (fetchedArray.count == 0) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.collectionView.mj_footer resetNoMoreData];
        }
    }];
}

- (void)loadMoreData {
    [self fetchMoreData:^(NSArray *fetchedArray) {
        [self.items addObjectsFromArray:fetchedArray];
        [self.collectionView reloadData];
        [self.collectionView.mj_footer endRefreshing];
        
        // 如果没有更多数据，显示无数据的footer
        if (fetchedArray.count == 0) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

- (void)handleLoadMoreEnd:(NSArray *)fetchedArray {
    if (fetchedArray.count == 0) {
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.collectionView.mj_footer endRefreshing];
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    HomeModel *model = self.items[indexPath.item];
    [self configureCell:cell withModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSMutableArray *imageUrls = [NSMutableArray array];
    for (HomeModel *model in self.items) {
        if (model.url) {
            [imageUrls addObject:model.url];
        }
    }
    HomeModel *selectedModel = self.items[indexPath.item];
    [DetailViewController showImages:imageUrls currentIndex:indexPath.item category:selectedModel.category currentPage:self.currentPage fromImageView:cell.imgView sourceViewController:self completion:nil];
}

- (void)scrollToItemAtIndex:(NSNumber *)index {
    NSInteger itemIndex = [index integerValue];
    if (itemIndex >= 0 && itemIndex < self.items.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
}

#pragma mark - Public Methods

- (void)updateItems:(NSArray *)newItems {
    if (!newItems) return;
    
    // 更新数据源
    [self.items addObjectsFromArray:newItems];
    
    // 刷新集合视图
    [self.collectionView reloadData];
}

#pragma mark - Helper Methods

- (void)configureCell:(HomeCollectionViewCell *)cell withModel:(HomeModel *)model {
    SDWebImageOptions options = SDWebImageProgressiveLoad | SDWebImageRetryFailed;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:thumbnail640URL(model.url)]
                   placeholderImage:[UIImage imageNamed:@"Default.png"]
                          options:options];
    [cell.likeButton setTitle:[NSString stringWithFormat:@"喜欢%u", model.favorite]
                    forState:UIControlStateNormal];
}

- (void)downloadImage:(NSString *)imageUrl {
    // 图片下载实现
    NSString *fileUrl = imageUrl;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设置中允许访问相册，以便下载图片" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:fileUrl] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image && finished) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下载失败" message:@"图片下载失败，请重试" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存失败" message:@"图片保存到相册失败" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存成功" message:@"图片已保存到相册" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - HomeCollectionViewCellDelegate

- (void)homeCollectionViewCellDidTapDownloadButton:(HomeCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.item];
    [self downloadImage:[NSString stringWithFormat:@"%s%@", base_wallpapers, model.url]];
}

- (void)homeCollectionViewCellDidTapDownLikeButton:(HomeCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.item];
    
    // 添加到收藏
    [[StoreManager sharedManager] addModel:model];
    
    // 更新界面
    [cell.likeButton setTitle:[NSString stringWithFormat:@"喜欢%u", model.favorite + 1]
                    forState:UIControlStateNormal];
    
    // 发送收藏请求
    [[URLFetcher sharedInstance] fetchLikeCount:model.favorite + 1 andID:model.ID];
}

- (void)homeCollectionViewCellDidTapDownDeleteButton:(HomeCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.item];
#if DEBUG
    if (!self.isStore) {
        [[URLFetcher sharedInstance] fetchDeleteURLsWithID:model.ID];
    }
#endif
    [self.items removeObject:model];
    [self.collectionView reloadData];
    [[StoreManager sharedManager] removeModelWithID:model.ID];
}

#pragma mark - WaterfallFlowLayoutDelegate

- (CGFloat)waterfallLayout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    if (indexPath.item < self.items.count) {
        HomeModel *model = self.items[indexPath.item];
        return [self calculateItemHeightWithModel:model itemWidth:itemWidth];
    }
    return itemWidth * golden_ratio; // 默认高度
}

- (CGFloat)calculateItemHeightWithModel:(HomeModel *)model itemWidth:(CGFloat)itemWidth {
    NSString *resolution = model.resolution;
    NSArray *resArr = [resolution componentsSeparatedByString:@"*"];
    
    if (resArr.count < 2) {
        return itemWidth * golden_ratio; // 默认高度
    }
    
    NSInteger origWidth = [resArr[0] integerValue];
    NSInteger origHeight = [resArr[1] integerValue];
    
    // 防止除零错误
    if (origHeight <= 0 || origWidth <= 0) {
        return itemWidth * golden_ratio; // 默认高度
    }
    
    // 计算原始宽高比
    CGFloat aspectRatio = (CGFloat)origHeight / (CGFloat)origWidth;
    
    // 根据宽度和原始比例计算高度
    CGFloat itemHeight = itemWidth * aspectRatio;
//    NSLog(@"===%f", itemWidth);
    
    return itemHeight;
}

// 设置瀑布流的内边距
- (UIEdgeInsets)edgeInsetsInWaterfallLayout:(UICollectionViewLayout *)layout {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

// 设置瀑布流的列数
- (NSInteger)columnCountInWaterfallLayout:(UICollectionViewLayout *)layout {
    return 2; // 两列瀑布流
}

// 设置瀑布流的行间距
- (CGFloat)rowMarginInWaterfallLayout:(UICollectionViewLayout *)layout {
    return 10.0;
}

// 设置瀑布流的列间距
- (CGFloat)columnMarginInWaterfallLayout:(UICollectionViewLayout *)layout {
    return 10.0;
}

- (void)fetchMoreData:(void (^__strong)(NSArray *__strong))completion {
}

- (void)fetchInitialData:(void (^__strong)(NSArray *__strong))completion {
}

@end 
