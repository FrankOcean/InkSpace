//
//  StoreViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import "StoreViewController.h"
#import "StoreManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "URLFetcher.h"
#import "HomeViewCell.h"
#import "HomeModel.h"
#import "MJRefresh.h"
#import "DetailViewController.h"
#import <Photos/Photos.h>

@interface StoreViewController ()<HomeViewCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <HomeModel *> *items; // 你的数据模型数组
@property (nonatomic, assign) NSUInteger current_id;

@end

@implementation StoreViewController

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
    self.title = @"收藏";
    [self setupTableView];

    // 加载数据
    [self request_head_data];
    // 配置刷新
    [self standardHeader];
    
}

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    // Set up any constraints for tableView if using Auto Layout
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *constraints;
    UIWindow *window = nil;
    for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
        if (windowScene.activationState == UISceneActivationStateForegroundActive) {
            window = windowScene.windows.firstObject;
            break;
        }
    }
    
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
    self.current_id = 0;
    
    NSArray *arr = [[StoreManager sharedManager] getAllModels];
    // 使用 reverseObjectEnumerator 获取反转顺序的 enumerator
    NSEnumerator *enumerator = [arr reverseObjectEnumerator];
    // 将反转后的元素加入新的可变数组中
    self.items = [NSMutableArray arrayWithArray:enumerator.allObjects];
    
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    
}

- (void)standardHeader {
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self request_head_data];
    }];
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
    [cell.likeButton setHidden:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [DetailViewController showImage:cell.imgView.image fromImageView:cell.imgView completion:^{
        
    }];
}

- (void)homeViewCellDidTapDownDeleteButton:(HomeViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HomeModel *model = self.items[indexPath.row];
    [[StoreManager sharedManager] removeModelWithID:model.ID];
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

