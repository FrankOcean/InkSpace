#import "PYCategoryViewController.h"
#import "PYCategoryView.h"
#import "ViewController.h"
#import "HotViewController.h"

@interface PYCategoryViewController () <PYCategoryViewDelegate, UIScrollViewDelegate>

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
        [[HotViewController alloc] initWithCategory:ContentTypeNewest],
        [[HotViewController alloc] initWithCategory:ContentTypeHottest],
        [[ViewController alloc] initWithCategory:2],
        [[ViewController alloc] initWithCategory:3],
        [[ViewController alloc] initWithCategory:1],
        [[ViewController alloc] initWithCategory:0]
    ];
    [self setupUI];
}

- (void)setupUI {
    // Setup category view
    CGFloat topInset = 0;
    if (@available(iOS 13.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        topInset = window.safeAreaInsets.top;
    } else {
        topInset = [[UIApplication sharedApplication] statusBarFrame].size.height;
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
    [self.contentScrollView setContentOffset:CGPointMake(index * self.view.frame.size.width, 0) animated:YES];
}

- (void)categoryView:(UIView *)categoryView didClickSearchButton:(NSString *)searchText {
    // Handle search button click
    NSLog(@"Search text: %@", searchText);
    // Implement your search logic here
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.categoryView updateIndicatorWithScrollView:scrollView];
}

@end

