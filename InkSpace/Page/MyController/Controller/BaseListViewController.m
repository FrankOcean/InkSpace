//
//  BaseListViewController.m
//  InkSpace
//
//  Created by puyang on 2025/1/10.
//

#import "BaseListViewController.h"
#import "DetailViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import <Photos/Photos.h>
#import "StoreManager.h"

@implementation BaseListViewController

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
    
    // 设置tableView的frame和背景色
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)configureNavigationBar {
    // 设置导航栏不透明
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    // 设置状态栏样式
    if (@available(iOS 13.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.shadowColor = nil;
        
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    
    // 确保导航栏在视图出现时保持白色
    [self configureNavigationBar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)configureRefreshControl {
    // 配置下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadInitialData];
    }];
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;
    
    // 配置上拉加载更多
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    footer.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer = footer;
}

- (void)loadInitialData {
    [self fetchInitialData:^(NSArray *fetchedArray) {
        self.items = [NSMutableArray arrayWithArray:fetchedArray];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        // 如果没有数据，显示无数据的footer
        if (fetchedArray.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer resetNoMoreData];
        }
    }];
}

- (void)loadMoreData {
    [self fetchMoreData:^(NSArray *fetchedArray) {
        [self.items addObjectsFromArray:fetchedArray];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
        // 如果没有更多数据，显示无数据的footer
        if (fetchedArray.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

- (void)handleLoadMoreEnd:(NSArray *)fetchedArray {
    if (fetchedArray.count == 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeModel *model = self.items[indexPath.row];
    return [self calculateCellHeight:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    HomeModel *model = self.items[indexPath.row];
    [self configureCell:cell withModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *imageUrls = [NSMutableArray array];
    for (HomeModel *model in self.items) {
        if (model.url) {
            [imageUrls addObject:model.url];
        }
    }
    [DetailViewController showImages:imageUrls currentIndex:indexPath.row category:self.category currentPage:self.currentPage fromImageView:cell.imgView sourceViewController:self completion:nil];
}

- (void)scrollToItemAtIndex:(NSNumber *)index {
    NSInteger rowIndex = [index integerValue];
    if (rowIndex >= 0 && rowIndex < self.items.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

#pragma mark - Helper Methods

- (CGFloat)calculateCellHeight:(HomeModel *)model {
    NSString *resolution = model.resolution;
    NSArray *resArr = [resolution componentsSeparatedByString:@"*"];
    NSInteger height = [resArr[0] integerValue];
    NSInteger width = [resArr[1] integerValue];
    CGFloat aspectRatio = width * 1.0 / height;
    CGFloat baseHeight = self.view.bounds.size.width - 40;
    CGFloat calculatedHeight = baseHeight * aspectRatio;
    return calculatedHeight > 0 ? calculatedHeight : 200;
}

- (void)configureCell:(HomeViewCell *)cell withModel:(HomeModel *)model {
    SDWebImageOptions options = SDWebImageProgressiveLoad | SDWebImageRetryFailed;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:thumbnail640URL(model.url)]
                   placeholderImage:[UIImage imageNamed:@"Default.png"]
                          options:options];
    [cell.likeButton setTitle:[NSString stringWithFormat:@"喜欢%u", model.favorite]
                    forState:UIControlStateNormal];
}

#pragma mark - HomeViewCellDelegate

- (void)homeViewCellDidTapDownDeleteButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
#if DEBUG
    if (!self.isStore) {
        [[URLFetcher sharedInstance] fetchDeleteURLsWithID:model.ID];
    }
#endif
    [self.items removeObject:model];
    [self.tableView reloadData];
    [[StoreManager sharedManager] removeModelWithID:model.ID];
}

- (void)homeViewCellDidTapDownLikeButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    model.favorite += 1;
    [[URLFetcher sharedInstance] fetchLikeCount:model.favorite andID:model.ID];
    [self.items replaceObjectAtIndex:indexPath.row withObject:model];
    [cell.likeButton setTitle:[NSString stringWithFormat:@"喜欢%u", model.favorite] forState:UIControlStateNormal];
    [self.tableView reloadData];
    [[StoreManager sharedManager] addModel:model];
}

- (void)homeViewCellDidTapDownloadButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    NSString *picString = [NSString stringWithFormat:@"%s%@", base_pic, model.url];
    [self downloadImage:picString];
}

- (void)downloadImage:(NSString *)imageUrl {
    // 创建进度条视图
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UIView *progressBgView = [[UIView alloc] init];
    progressBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    progressBgView.layer.cornerRadius = 10;
    [window addSubview:progressBgView];
    
    UILabel *progressLabel = [[UILabel alloc] init];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.font = [UIFont systemFontOfSize:14];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.text = @"下载中...0%";
    [progressBgView addSubview:progressLabel];
    
    UIProgressView *progressView = [[UIProgressView alloc] init];
    progressView.progressTintColor = [UIColor whiteColor];
    progressView.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    [progressBgView addSubview:progressView];
    
    // 设置约束
    progressBgView.translatesAutoresizingMaskIntoConstraints = NO;
    progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [progressBgView.centerXAnchor constraintEqualToAnchor:window.centerXAnchor],
        [progressBgView.centerYAnchor constraintEqualToAnchor:window.centerYAnchor],
        [progressBgView.widthAnchor constraintEqualToConstant:200],
        [progressBgView.heightAnchor constraintEqualToConstant:80],
        
        [progressLabel.topAnchor constraintEqualToAnchor:progressBgView.topAnchor constant:15],
        [progressLabel.centerXAnchor constraintEqualToAnchor:progressBgView.centerXAnchor],
        
        [progressView.leftAnchor constraintEqualToAnchor:progressBgView.leftAnchor constant:20],
        [progressView.rightAnchor constraintEqualToAnchor:progressBgView.rightAnchor constant:-20],
        [progressView.topAnchor constraintEqualToAnchor:progressLabel.bottomAnchor constant:15],
        [progressView.heightAnchor constraintEqualToConstant:2]
    ]];
    
    // 开始下载
    NSURL *url = [NSURL URLWithString:imageUrl];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                                                        options:SDWebImageDownloaderHighPriority
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        // 更新进度
        float progress = (float)receivedSize / expectedSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progress = progress;
            progressLabel.text = [NSString stringWithFormat:@"下载中...%d%%", (int)(progress * 100)];
        });
    }
                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 移除进度条
            [UIView animateWithDuration:0.3 animations:^{
                progressBgView.alpha = 0;
            } completion:^(BOOL finished) {
                [progressBgView removeFromSuperview];
            }];
            
            if (image && finished) {
                [self saveImageToPhotoLibrary:image];
            }
        });
    }];
}

- (void)saveImageToPhotoLibrary:(UIImage *)image {
    // Ensure we're on the main thread
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveImageToPhotoLibrary:image];
        });
        return;
    }
    
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                // 保存图片到相册
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            [self showToast:@"图片已保存"];
                        } else {
                            NSString *errorMessage = error ? error.localizedDescription : @"保存失败";
                            [self showToast:errorMessage];
                        }
                    });
                }];
            } else {
                [self showToast:@"没有权限访问相册"];
            }
        });
    }];
}

- (void)showToast:(NSString *)message {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    
    // 创建一个带有圆角的视图
    UIView *toastView = [[UIView alloc] init];
    toastView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    toastView.layer.cornerRadius = 10;
    toastView.clipsToBounds = YES;
    [window addSubview:toastView];
    
    // 添加消息标签
    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    [toastView addSubview:label];
    
    // 设置约束
    toastView.translatesAutoresizingMaskIntoConstraints = NO;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 计算文本大小
    CGSize maxSize = CGSizeMake(window.bounds.size.width - 80, CGFLOAT_MAX);
    CGSize labelSize = [message boundingRectWithSize:maxSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: label.font}
                                           context:nil].size;
    
    // 设置toastView的约束
    [NSLayoutConstraint activateConstraints:@[
        [toastView.centerXAnchor constraintEqualToAnchor:window.centerXAnchor],
        [toastView.bottomAnchor constraintEqualToAnchor:window.bottomAnchor constant:-100],
        [toastView.widthAnchor constraintEqualToConstant:labelSize.width + 40],
        [toastView.heightAnchor constraintEqualToConstant:labelSize.height + 20]
    ]];
    
    // 设置label的约束
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:toastView.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:toastView.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:toastView.leadingAnchor constant:5],
        [label.trailingAnchor constraintEqualToAnchor:toastView.trailingAnchor constant:-5]
    ]];
    
    // 2秒后移除toast
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            toastView.alpha = 0;
        } completion:^(BOOL finished) {
            [toastView removeFromSuperview];
        }];
    });
}

#pragma mark - To be implemented by subclasses

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    // 子类必须实现
}

- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion {
    // 子类必须实现
}

- (void)updateItems:(NSArray *)newItems {
    // 更新数据源
    [self.items addObjectsFromArray:newItems];
    
    // 刷新视图
    [self.tableView reloadData];
}

@end
