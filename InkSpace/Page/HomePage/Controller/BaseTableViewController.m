//
//  BaseTableViewController.m
//  InkSpace
//
//  Created by puyang on 2025/1/10.
//

#import "BaseTableViewController.h"
#import "HomeViewCell.h"

@interface BaseTableViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self standardHeader];
    [self loadData];
}

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加 loading indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    [self.loadingIndicator startAnimating];
    
    UIWindow *window = nil;
    for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
        if (windowScene.activationState == UISceneActivationStateForegroundActive) {
            window = windowScene.windows.firstObject;
            break;
        }
    }
    
    NSArray *constraints = @[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],// constant:self.topOffset],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:window.safeAreaInsets.bottom]
    ];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        if (@available(iOS 15.0, *)) {
            _tableView.prefetchingEnabled = NO;
        }
        [_tableView registerNib:[UINib nibWithNibName:@"HomeViewCell" bundle:nil] forCellReuseIdentifier:@"HomeViewCell"];
    }
    return _tableView;
}

- (void)standardHeader {
    // 子类实现
}

- (void)loadData {
    // 子类实现
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0; // 子类实现
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil; // 子类实现
}

// 添加显示和隐藏 loading 的方法
- (void)showLoading {
    [self.loadingIndicator startAnimating];
}

- (void)hideLoading {
    [self.loadingIndicator stopAnimating];
}

@end
