#import "PYCategoryViewController.h"
#import "PYCategoryView.h"
#import "CollectionViewController.h"
#import "HotCollectionViewController.h"
#import "BaseNavigationViewController.h"
#import "PYSearch.h"
#import "MyViewController.h"

@interface PYCategoryViewController () <PYCategoryViewDelegate, UIScrollViewDelegate, PYSearchViewControllerDelegate>

@property (nonatomic, strong) PYCategoryView *categoryView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong, readwrite) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *titles;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation PYCategoryViewController

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                               titles:(NSArray<NSString *> *)titles {
    self = [super init];
    if (self) {
        NSAssert(viewControllers.count == titles.count, @"viewControllers count must equal to titles count");
        _viewControllers = viewControllers;
        _titles = titles;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _titles = @[@"最新", @"最热", @"超清", @"人物", @"动漫", @"美女"];
    _viewControllers = @[
        [[HotCollectionViewController alloc] initWithCategory:ContentTypeNewest],
        [[HotCollectionViewController alloc] initWithCategory:ContentTypeHottest],
        [[CollectionViewController alloc] initWithCategory:2],
        [[CollectionViewController alloc] initWithCategory:3],
        [[CollectionViewController alloc] initWithCategory:1],
        [[CollectionViewController alloc] initWithCategory:0]
    ];
    [self setupUI];
}

- (void)setupUI {
    // Setup category view
    CGFloat topInset = 0;

    // 获取当前活跃的 UIWindowScene
    NSArray<UIScene *> *connectedScenes = UIApplication.sharedApplication.connectedScenes.allObjects;
    for (UIScene *scene in connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState == UISceneActivationStateForegroundActive | windowScene.activationState == UISceneActivationStateForegroundInactive) {
                // 使用 UIStatusBarManager 获取状态栏高度
                UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
                topInset = statusBarManager.statusBarFrame.size.height;
                NSLog(@"====%f", topInset);
                break;
            }
        }
    }
    
    CGFloat categoryViewHeight = 84;
    self.categoryView = [[PYCategoryView alloc] initWithFrame:CGRectMake(0, topInset, self.view.frame.size.width, categoryViewHeight)
                                                     titles:self.titles];
    self.categoryView.delegate = self;
    [self.view addSubview:self.categoryView];
    
    // Setup content scroll view
    CGFloat contentY = CGRectGetMaxY(self.categoryView.frame);
    CGFloat contentHeight = self.view.frame.size.height - contentY;
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, contentY, self.view.frame.size.width, contentHeight)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.contentScrollView];
    
    // Add child view controllers
    CGFloat contentWidth = self.view.frame.size.width * self.viewControllers.count;
    self.contentScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:vc];
        vc.view.frame = CGRectMake(idx * self.view.frame.size.width, 0, self.view.frame.size.width, contentHeight);
        [self.contentScrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }];
}

#pragma mark - PYCategoryViewDelegate

- (void)categoryView:(UIView *)categoryView didSelectItemAtIndex:(NSInteger)index {
    [self.contentScrollView setContentOffset:CGPointMake(index * self.view.frame.size.width, 0) animated:NO];
}

- (void)categoryView:(UIView *)categoryView didClickSearchButton:(NSString *)searchText {
    // Handle search button click
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

- (void)categoryView:(UIView *)categoryView didClickProfileButton:(NSString *)text {
    MyViewController *myVc = [[MyViewController alloc] init];
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:myVc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - PYSearchViewControllerDelegate

- (void)searchViewController:(PYSearchViewController *)searchViewController didSearchWithSearchBar:(UISearchBar *)searchBar searchText:(NSString *)searchText {
    HotCollectionViewController *hot = [[HotCollectionViewController alloc] init];
    hot.contentType = ContentTypeSearch;
    hot.content = searchText;
    [searchViewController.navigationController pushViewController:hot animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        [self.categoryView updateIndicatorWithScrollView:scrollView];
        
        // 禁止垂直滚动
        if (scrollView.contentOffset.y != 0) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // 确保contentScrollView不会垂直滚动
    self.contentScrollView.alwaysBounceVertical = NO;
    
    // 遍历所有子控制器，设置其scrollView的contentInset
    for (UIViewController *vc in self.viewControllers) {
        if ([vc.view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)vc.view;
            scrollView.contentInset = UIEdgeInsetsZero;
        } else {
            // 查找子视图中的scrollView
            for (UIView *subview in vc.view.subviews) {
                if ([subview isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView *)subview;
                    scrollView.contentInset = UIEdgeInsetsZero;
                }
            }
        }
    }
}

@end

