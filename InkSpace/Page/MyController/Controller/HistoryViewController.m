//
//  HistoryViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import "HistoryViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HomeViewCell.h"
#import "HomeModel.h"
#import "URLFetcher.h"
#import "MJRefresh.h"
#import "DetailViewController.h"
#import <Photos/Photos.h>
#import "StoreManager.h"

@interface HistoryViewController ()<HomeViewCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <HomeModel *> *items; // 你的数据模型数组
@property (nonatomic, assign) NSUInteger current_id;
@property (nonatomic, assign) NSUInteger history_id;

@end

@implementation HistoryViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count == 1) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"历史记录";
    [self setupTableView];

    // 加载数据
    [self request_head_data];
    // 配置刷新
    [self standardHeader];

    self.history_id = [HomeModel getHistoricIDForCategory:self.category];
    NSLog(@"%lu \n -----------\n ", self.history_id);

}

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    // Set up any constraints for tableView if using Auto Layout
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *constraints;
    
    constraints = @[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ];

    [NSLayoutConstraint activateConstraints:constraints];

}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200; // 一个合理的预估值
        if (@available(iOS 15.0, *)) {
            _tableView.prefetchingEnabled = NO;
        }
        // 注册UITableViewCell
        [_tableView registerNib:[UINib nibWithNibName:@"HomeViewCell" bundle:nil] forCellReuseIdentifier:@"HomeViewCell"];
    }
    return _tableView;
}

- (void)request_head_data {
    self.items = [[NSMutableArray alloc] init];
    self.current_id = [HomeModel getHistoricIDForCategory:self.category];
    
    URLFetcher *fetcher = [URLFetcher sharedInstance];
    [fetcher fetchURLsWithCategory:self.category andCurrentId:self.current_id andCompletion:^(NSArray * _Nonnull fetchedArray) {
        HomeModel *model = [fetchedArray lastObject];
        self.current_id = model.ID;
        [self.items addObjectsFromArray:[NSMutableArray arrayWithArray:fetchedArray]];
        [self.tableView reloadData];
    }];
    
}

- (void)request_foot_data {
    URLFetcher *fetcher = [URLFetcher sharedInstance];
    [fetcher fetchURLsWithCategory:self.category andCurrentId:self.current_id andCompletion:^(NSArray * _Nonnull fetchedArray) {
        HomeModel *model = [fetchedArray lastObject];
        self.current_id = model.ID;
        [self.items addObjectsFromArray:[NSMutableArray arrayWithArray:fetchedArray]];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)standardHeader {
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self request_foot_data];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UITableView *tableView = (UITableView *)scrollView;
    // Get visible rows
    NSArray *visibleIndexPaths = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        // Access the model corresponding to the indexPath
        HomeModel *model = self.items[indexPath.row];
        // 记录历史记录
        if(model.ID >= self.history_id) {
            [HomeModel setHistoricID:model.ID forCategory:self.category];
        }
        
//        NSLog(@"%lu \n %lu -------------\n ", (unsigned long)model.ID, self.history_id);
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeModel *model = self.items[indexPath.row];
    NSString *resolution = model.resolution;
    NSArray *resArr = [resolution componentsSeparatedByString:@"*"];
    NSInteger height = [resArr[0] integerValue];
    NSInteger width = [resArr[1] integerValue];
    CGFloat aspectRatio = width * 1.0 / height;
    CGFloat baseHeight = SCREEN_WIDTH - 40; // 你的基础高度
    CGFloat calculatedHeight = baseHeight * aspectRatio;
    return calculatedHeight > 0 ? calculatedHeight : 200;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    HomeModel *model = self.items[indexPath.row];
    // 使用SDWebImage或其他方式加载图片
    SDWebImageOptions options = SDWebImageProgressiveLoad | SDWebImageRetryFailed;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:thumbnail640URL(model.url)] placeholderImage:[UIImage imageNamed:@"Default.png"] options:options];
    [cell.likeButton setTitle:[NSString stringWithFormat:@"喜欢%u",model.favorite] forState:UIControlStateNormal];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [DetailViewController showImage:cell.imgView.image fromImageView:cell.imgView completion:^{
        
    }];
}

// HomeViewCellDelegate 方法
- (void)homeViewCellDidTapDownLikeButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    model.favorite += 1;
    [[URLFetcher sharedInstance] fetchLikeCount:model.favorite andID:model.ID];
    [[StoreManager sharedManager] addModel:model];
    [self.items replaceObjectAtIndex:indexPath.row withObject:model];
    // 刷新单元格
    [self.tableView reloadData];
}

- (void)homeViewCellDidTapDownDeleteButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    [[URLFetcher sharedInstance] fetchDeleteURLsWithID:model.ID];
    [self.items removeObject:model];
    [self.tableView reloadData];
}

- (void)homeViewCellDidTapDownloadButton:(HomeViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    NSString *picString = [NSString stringWithFormat:@"%s%@", base_pic, model.url];
    NSURL *imageURL = [NSURL URLWithString:picString];
    
 
    // 下载并缓存图片
    [[SDWebImageManager sharedManager] loadImageWithURL:imageURL
                                                options:0
                                               progress:nil
                                              completed:^(UIImage * _Nullable image,
                                                          NSData * _Nullable data,
                                                          NSError * _Nullable error,
                                                          SDImageCacheType cacheType,
                                                          BOOL finished,
                                                          NSURL * _Nullable imageURL) {
        if (image && finished) {
            // 图片下载并缓存成功, 请求相册权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // 保存图片到相册
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                    [self showAlertWithTitle:@"成功" message:@"图片已成功保存到相册"];
                } else {
                    [self showAlertWithTitle:@"错误" message:@"没有权限访问相册"];
                }
            }];
        } else {
            // 处理错误
            [self showAlertWithTitle:@"保存失败" message:error.localizedDescription];
        }
    }];
    
}

// 保存图片后的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [self showAlertWithTitle:@"保存失败" message:error.localizedDescription];
    } else {
        [self showAlertWithTitle:@"成功" message:@"图片已成功保存到相册"];
    }
}

// 显示提示框
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        dispatch_async(dispatch_get_main_queue(), ^{
              
              UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
              [alert addAction:okAction];
              [self presentViewController:alert animated:YES completion:nil];
              
          });
      });
    
}



@end
