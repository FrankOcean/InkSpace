//
//  MyViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/12.
//

#import "MyViewController.h"
#import "StoreViewController.h"
#import "HistoryHomeController.h"
#import "UserAgreementViewController.h"
#import <MessageUI/MessageUI.h>

#if DEBUG
#import "FLEXManager.h"
#endif

@interface MyViewController ()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation MyViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];  
    self.title = @"设置";
    
    self.items = @[@"收藏", @"清除缓存", @"历史记录", @"用户协议", @"反馈"];
#if DEBUG
    self.items = @[@"收藏", @"清除缓存", @"历史记录", @"用户协议", @"反馈", @"调试"];
#endif
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *selectedItem = self.items[indexPath.row];
    // 根据选择项执行相应操作
    if ([selectedItem isEqualToString:@"收藏"]) {
        // 收藏操作
        [self handleFavorite];
    } else if ([selectedItem isEqualToString:@"清除缓存"]) {
        // 清除缓存操作
        [self handleClearCache];
    } else if ([selectedItem isEqualToString:@"历史记录"]) {
        // 历史记录操作
        [self handleHistory];
    } else if ([selectedItem isEqualToString:@"用户协议"]) {
        // 用户协议操作
        [self handleUserAgreement];
    } else if ([selectedItem isEqualToString:@"反馈"]) {
        // 反馈操作
        [self handleFeedback];
    } else if ([selectedItem isEqualToString:@"评价"]) {
        // 评价操作
        [self handleReview];
    } else if ([selectedItem isEqualToString:@"调试"]) {
#if DEBUG
        [[FLEXManager sharedManager] showExplorer];
#endif
    }
}

- (void)handleFavorite {
    // 实现收藏操作
    NSLog(@"收藏操作");
    StoreViewController *storeVC = [[StoreViewController alloc] init];
    [self.navigationController pushViewController:storeVC animated:YES];
}

- (void)handleClearCache {
    // 实现清除缓存操作
    NSLog(@"清除缓存操作");
    // 显示正在清理缓存的弹窗
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"正在清除缓存..."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        // 在弹窗显示之后开始清理缓存操作
        [self clearCacheWithCompletion:^{
            // 缓存清理完成后，更新弹窗内容
            alertController.message = @"缓存已清除";
            // 延时0.5秒后自动消失
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             repeats:NO
                                               block:^(NSTimer * _Nonnull timer) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }];
}

- (void)clearCacheWithCompletion:(void (^)(void))completion {
    // 新线程执行缓存清理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取应用缓存目录路径
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [cachePaths firstObject];
        
        // 使用文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // 获取缓存目录下的所有文件
        NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:nil];
        
        // 遍历并删除缓存文件
        for (NSString *filePath in cacheFiles) {
            NSString *fullPath = [cacheDirectory stringByAppendingPathComponent:filePath];
            [fileManager removeItemAtPath:fullPath error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 清理完成后调用 completion 回调
            if (completion) {
                completion();
            }
        });
    });
}

- (void)handleHistory {
    // 实现历史记录操作
    NSLog(@"历史记录操作");
    HistoryHomeController *hisHome = [[HistoryHomeController alloc] init];
    [self.navigationController pushViewController:hisHome animated:YES];
}

- (void)handleUserAgreement {
    // 实现用户协议操作
    NSLog(@"用户协议操作");
    UserAgreementViewController *userVC = [[UserAgreementViewController alloc] init];
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)handleFeedback {
    // 实现反馈操作
    NSLog(@"反馈操作");
    if ([MFMailComposeViewController canSendMail]) {
        [self presentMailComposer];
    } else {
        [self showEmailNotAvailableAlert];
    }

}

- (void)handleReview {
    // 实现评价操作
    NSLog(@"评价操作");
}

- (void)presentMailComposer {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    // 设置收件人
    [mailComposer setToRecipients:@[@"impuyang@gmail.com"]];
    
    // 设置主题
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    [mailComposer setSubject:[NSString stringWithFormat:@"%@ App 反馈", appName]];
    
    // 设置邮件正文
    NSString *deviceInfo = [NSString stringWithFormat:@"\n\n\n--------------------\n设备信息：\niOS版本：%@\n设备型号：%@\nApp版本：%@",
                           [[UIDevice currentDevice] systemVersion],
                           [[UIDevice currentDevice] model],
                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    [mailComposer setMessageBody:deviceInfo isHTML:NO];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (void)showEmailNotAvailableAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法发送邮件"
                                                                 message:@"请检查您的邮件设置，确保至少设置了一个邮件账户。"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                      error:(NSError *)error {
    
    NSString *message;
    switch (result) {
        case MFMailComposeResultSent:
            message = @"反馈已发送，感谢您的反馈！";
            break;
        case MFMailComposeResultFailed:
            message = @"发送失败，请稍后重试。";
            break;
        default:
            message = nil;
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        if (message) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}


@end
