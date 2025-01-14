//
//  BaseTableViewController.m
//  InkSpace
//
//  Created by puyang on 2025/1/10.
//

#import "BaseTableViewController.h"
#import "HomeViewCell.h"

@implementation BaseTableViewController

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
    [self setupTableView];
    [self standardHeader];
    [self loadData];
}

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat tabBarHeight = 49.0;
    UIWindow *window = nil;
    for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
        if (windowScene.activationState == UISceneActivationStateForegroundActive) {
            window = windowScene.windows.firstObject;
            break;
        }
    }
    
    if (window.safeAreaInsets.top > 50) {
        self.topOffset = window.safeAreaInsets.top;
    }
    
    if (window.safeAreaInsets.bottom > 0) {
        tabBarHeight = 83.0;
    }
    
    NSArray *constraints = @[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.topOffset],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-tabBarHeight + window.safeAreaInsets.bottom]
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

@end
