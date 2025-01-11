//
//  BaseViewController.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/9.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "ContentBaseViewController.h"
#import "BaseNavigationViewController.h"
#import "ViewController.h"
#import "HotViewController.h"
#import "PYSearch.h"

@interface ContentBaseViewController () <JXCategoryViewDelegate, PYSearchViewControllerDelegate>

@property (nonatomic, strong) PYSearchViewController *searchViewController;

@end

@implementation ContentBaseViewController

#pragma mark - View life cycle

- (BOOL)hasNotch {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        return window.safeAreaInsets.top > 20;
    }
    return NO;
}

- (BOOL)hasDynamicIsland {
    if (@available(iOS 16.0, *)) {
        NSString *model = [[UIDevice currentDevice] model];
        return [model containsString:@"iPhone"] && [self hasNotch] && UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.top > 50;
    }
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.listContainerView];
    
    [self setUpSeachButton];
    			
}

- (void)setUpSeachButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    // 设置按钮位置，与categoryView在同一水平线上
    if ([self hasDynamicIsland]) {
        button.frame = CGRectMake(0, 39 + 20, 80, 40);
    } else {
        button.frame = CGRectMake(0, 20, 80, 40);
    }
    [button setTitle:@"搜索" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

// 按钮点击事件处理函数
- (void)buttonTapped {
    NSArray *hotSeaches = @[@"美女", @"动漫", @"人物", @"写真", @"艺术"];
    PYSearchViewController *searchViewController = [PYSearchViewController searchViewControllerWithHotSearches:hotSeaches searchBarPlaceholder:@"" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        [searchViewController.navigationController pushViewController:[[UIViewController alloc] init] animated:YES];
    }];
    searchViewController.hotSearchStyle = PYHotSearchStyleBorderTag;
    searchViewController.searchHistoryStyle = PYSearchHistoryStyleDefault;
    searchViewController.searchHistoriesCount = 10;
    searchViewController.searchSuggestionHidden = YES;
    searchViewController.searchViewControllerShowMode = PYSearchViewControllerShowDefault;
    searchViewController.searchResultShowMode = PYSearchResultShowModePush;
    searchViewController.delegate = self;
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - PYSearchViewControllerDelegate
- (void)searchViewController:(PYSearchViewController *)searchViewController didSearchWithSearchBar:(UISearchBar *)searchBar searchText:(NSString *)searchText {
    HotViewController *hot = [[HotViewController alloc] init];
    hot.contentType = ContentTypeSearch;
    hot.content = searchText;
    searchViewController.searchResultController = hot;    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.categoryView.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self preferredCategoryViewHeight]);
    self.listContainerView.frame = CGRectMake(0, [self preferredCategoryViewHeight], self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 处于第一个item的时候，才允许屏幕边缘手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = (self.categoryView.selectedIndex == 0);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 离开页面的时候，需要恢复屏幕边缘手势，不能影响其他页面
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - Custom Accessors

// 分页菜单视图
- (JXCategoryBaseView *)categoryView {
    if (!_categoryView) {
        _categoryView = [self preferredCategoryView];
        _categoryView.delegate = self;
        
        // !!!: 将列表容器视图关联到 categoryView
        _categoryView.listContainer = self.listContainerView;
    }
    return _categoryView;
}

// 列表容器视图
- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _listContainerView;
}

#pragma mark - Public

- (JXCategoryBaseView *)preferredCategoryView {
    return [[JXCategoryBaseView alloc] init];
}

- (CGFloat)preferredCategoryViewHeight {
    return 40;
}

#pragma mark - JXCategoryViewDelegate

// 点击选中或者滚动选中都会调用该方法。适用于只关心选中事件，不关心具体是点击还是滚动选中的。
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    // 侧滑手势处理
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
}

// 滚动选中的情况才会调用该方法
- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - JXCategoryListContainerViewDelegate

// 返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

// 返回各个列表菜单下的实例，该实例需要遵守并实现 <JXCategoryListContentViewDelegate> 协议
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    ViewController *list = [[ViewController alloc] init];
    
    if (index == 0) {
        HotViewController *hot = [[HotViewController alloc] init];
        hot.contentType = ContentTypeNewest;
        return hot;
    } else if (index == 1) {
        HotViewController *hot = [[HotViewController alloc] init];
        hot.contentType = ContentTypeHottest;
        return hot;
    } else if (index == 2) {
        list.category = 2;
    } else if (index == 3) {
        list.category = 3;
    } else if (index == 4) {
        list.category = 1;
    } else if (index == 5) {
        list.category = 0;
    }
    return list;
}

@end
