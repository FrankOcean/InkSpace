//
//  BaseListViewController.m
//  InkSpace
//
//  Created by puyang on 2025/1/10.
//

#import "BaseListViewController.h"
#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import <Photos/Photos.h>

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray array];
    self.currentPage = 0;
    [self configureRefreshControl];
    [self loadInitialData];
}

- (void)loadInitialData {
    [self fetchInitialData:^(NSArray *fetchedArray) {
        self.items = [NSMutableArray arrayWithArray:fetchedArray];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)loadMoreData {
    [self fetchMoreData:^(NSArray *fetchedArray) {
        [self.items addObjectsFromArray:fetchedArray];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        [self handleLoadMoreEnd:fetchedArray];
    }];
}

- (void)configureRefreshControl {
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadInitialData];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
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
    [DetailViewController showImage:cell.imgView.image fromImageView:cell.imgView completion:nil];
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

- (void)homeViewCellDidTapDownloadButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    NSString *picString = [NSString stringWithFormat:@"%s%@", base_pic, model.url];
    
    // 检查相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self downloadImage:picString];
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self downloadImage:picString];
    }
}

- (void)downloadImage:(NSString *)imageUrl {
    NSURL *url = [NSURL URLWithString:imageUrl];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                                                        options:SDWebImageDownloaderHighPriority
                                                       progress:nil
                                                      completed:^(UIImage * _Nullable image,
                                                                NSData * _Nullable data,
                                                                NSError * _Nullable error,
                                                                BOOL finished) {
        if (image && finished) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 可以添加下载成功的提示
                    });
                }
            }];
        }
    }];
}

#pragma mark - To be implemented by subclasses

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    // 子类必须实现
}

- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion {
    // 子类必须实现
}

@end
