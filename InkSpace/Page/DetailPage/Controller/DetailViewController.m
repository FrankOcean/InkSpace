//
//  DetailViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/3.
//

#import "DetailViewController.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import "URLFetcher.h"
#import "HomeModel.h"
#import "BaseCollectionListViewController.h"

@interface DetailViewController ()<UIScrollViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) UIImageView *sourceImageView;
@property (nonatomic, copy) PhotoViewCompletionBlock completionBlock;
@property (nonatomic, assign) CGRect sourceFrame;
@property (nonatomic, assign) CGRect targetFrame;
@property (nonatomic, assign) CGSize sourceImageSize;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *imageCache;

// 新增的UI元素
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *imageInfoLabel;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;

@end

@implementation DetailViewController

+ (void)showImage:(UIImage *)image fromImageView:(UIImageView *)sourceImageView completion:(nullable PhotoViewCompletionBlock)completion {
    // 创建一个临时的 DetailViewController 来显示单个图片
    DetailViewController *photoVC = [[DetailViewController alloc] init];
    photoVC.imageUrls = @[];
    photoVC.currentIndex = 0;
    photoVC.sourceImageView = sourceImageView;
    photoVC.completionBlock = completion;
    photoVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    photoVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIViewController *topVC = nil;
    UIScene *scene = [[UIApplication sharedApplication].connectedScenes anyObject];
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindow *window = [(UIWindowScene *)scene windows].firstObject;
        topVC = window.rootViewController;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        #pragma clang diagnostic pop
    }
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    [topVC presentViewController:photoVC animated:NO completion:nil];
    
    // 设置单个图片
    photoVC.image = image;
    [photoVC setupSingleImageView];
}

+ (void)showImages:(NSArray<NSString *> *)imageUrls currentIndex:(NSInteger)index fromImageView:(UIImageView *)sourceImageView sourceViewController:(id)sourceVC completion:(nullable PhotoViewCompletionBlock)completion {
    [self showImages:imageUrls currentIndex:index category:0 currentPage:0 fromImageView:sourceImageView sourceViewController:sourceVC completion:completion];
}

+ (void)showImages:(NSArray<NSString *> *)imageUrls currentIndex:(NSInteger)index category:(NSInteger)category currentPage:(NSInteger)currentPage fromImageView:(UIImageView *)sourceImageView sourceViewController:(id)sourceVC completion:(nullable PhotoViewCompletionBlock)completion {
    if (!imageUrls.count) return;
    
    DetailViewController *photoVC = [[DetailViewController alloc] init];
    photoVC.imageUrls = [NSMutableArray arrayWithArray:imageUrls];
    photoVC.currentIndex = index;
    photoVC.category = category;
    photoVC.currentPage = currentPage;
    photoVC.sourceImageView = sourceImageView;
    photoVC.sourceViewController = sourceVC;
    photoVC.completionBlock = completion;
    photoVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    photoVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIViewController *topVC = nil;
    UIScene *scene = [[UIApplication sharedApplication].connectedScenes anyObject];
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindow *window = [(UIWindowScene *)scene windows].firstObject;
        topVC = window.rootViewController;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        #pragma clang diagnostic pop
    }
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    [topVC presentViewController:photoVC animated:NO completion:nil];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.imageCache = [NSMutableDictionary dictionary];
    
    // 根据是否有 imageUrls 来决定使用哪种方式显示图片
    if (self.imageUrls.count > 0) {
        [self setupPageViewController];
    } else if (self.image) {
        [self setupSingleImageView];
    }
    
    [self setupBottomView];
    [self setupGestureRecognizers];
    [self setupLoadingIndicator];
}

- (void)setupPageViewController {
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = self.view.bounds;
    [self.pageViewController didMoveToParentViewController:self];
    
    // Set initial view controller
    UIViewController *initialVC = [self viewControllerAtIndex:self.currentIndex];
    [self.pageViewController setViewControllers:@[initialVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.imageUrls.count) {
        return nil;
    }
    
    UIViewController *pageVC = [[UIViewController alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [pageVC.view addSubview:imageView];
    
    // 加载图片
    NSString *imageUrl = self.imageUrls[index];
    [self loadImage:imageUrl forImageView:imageView];
    
    return pageVC;
}

- (void)loadImage:(NSString *)imageUrl forImageView:(UIImageView *)imageView {
    // 检查缓存
    NSNumber *key = @([self.imageUrls indexOfObject:imageUrl]);
    UIImage *cachedImage = self.imageCache[key];
    
    if (cachedImage) {
        imageView.image = cachedImage;
        return;
    }
    
    // 显示加载指示器
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    activityIndicator.center = imageView.center;
    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    // 使用 thumbnail640URL 处理 URL
    NSString *processedUrl = thumbnail640URL(imageUrl);
    
    // 下载图片
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:processedUrl] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        [activityIndicator removeFromSuperview];
        
        if (image && finished) {
            imageView.image = image;
            self.imageCache[key] = image;
            
            // 更新底部信息
            [self updateImageInfo:image];
        } else {
            // 显示错误占位图
            imageView.image = [UIImage imageNamed:@"Default.png"];
        }
    }];
}

- (void)updateImageInfo:(UIImage *)image {
    if (!image) return;
    
    NSString *dimensions = [NSString stringWithFormat:@"%dx%d", (int)image.size.width*2, (int)image.size.height*2];
    float sizeInMB = image.size.width * image.size.height * 4 / (1024.0 * 1024.0); // 粗略估算
    self.imageInfoLabel.text = [NSString stringWithFormat:@"尺寸: %@\n大小: %.1f MB", dimensions, sizeInMB];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound || index == 0) {
        // 如果是第一个图片，尝试加载更多历史图片
        if (self.category > 0 && !self.isLoadingMore) {
            [self loadMoreImages:NO];
            // 返回当前视图控制器，等待加载完成
            return viewController;
        }
        // 只有在没有更多历史图片时才循环到最后一个
        return [self viewControllerAtIndex:self.imageUrls.count - 1];
    }
    return [self viewControllerAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound || index == self.imageUrls.count - 1) {
        // 如果是最后一个图片，尝试加载更多图片
        if (self.category > 0 && !self.isLoadingMore) {
            [self loadMoreImages:YES];
            // 返回当前视图控制器，等待加载完成
            return viewController;
        }
        // 只有在没有更多图片时才循环到第一个
        return [self viewControllerAtIndex:0];
    }
    return [self viewControllerAtIndex:index + 1];
}

- (NSInteger)indexOfViewController:(UIViewController *)viewController {
    UIImageView *imageView = viewController.view.subviews.firstObject;
//    NSString *imageUrl = self.imageUrls[self.currentIndex];
    
    // 检查当前图片是否已加载
    if (imageView.image) {
        for (NSInteger i = 0; i < self.imageUrls.count; i++) {
//            NSString *url = self.imageUrls[i];
            NSNumber *key = @(i);
            UIImage *cachedImage = self.imageCache[key];
            
            if (cachedImage == imageView.image) {
                return i;
            }
        }
    }
    
    return self.currentIndex;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        UIViewController *currentVC = pageViewController.viewControllers.firstObject;
        NSInteger newIndex = [self indexOfViewController:currentVC];
        if (newIndex != self.currentIndex) {
            self.currentIndex = newIndex;
            [self updateSourceViewControllerPosition];
        }
    }
}

- (void)updateSourceViewControllerPosition {
    if ([self.sourceViewController isKindOfClass:[BaseCollectionListViewController class]]) {
        BaseCollectionListViewController *collectionVC = (BaseCollectionListViewController *)self.sourceViewController;
        [collectionVC scrollToItemAtIndex:@(self.currentIndex)];
    }
}

#pragma mark - Setup Methods

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.scrollView];
}

- (void)setupImageView {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
}

- (void)setupBottomView {
    // 底部视图
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self.view addSubview:self.bottomView];
    
    // 设置底部视图约束
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.bottomView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bottomView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bottomView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.bottomView.heightAnchor constraintEqualToConstant:80]
    ]];
    
    // 图片信息标签
    self.imageInfoLabel = [[UILabel alloc] init];
    self.imageInfoLabel.textColor = [UIColor whiteColor];
    self.imageInfoLabel.font = [UIFont systemFontOfSize:14];
    self.imageInfoLabel.numberOfLines = 2;
    [self.bottomView addSubview:self.imageInfoLabel];
    
    // 设置图片信息
    NSString *dimensions = [NSString stringWithFormat:@"%dx%d", (int)self.image.size.width*2, (int)self.image.size.height*2];
    float sizeInMB = self.image.size.width * self.image.size.height * 4 / (1024.0 * 1024.0); // 粗略估算
    self.imageInfoLabel.text = [NSString stringWithFormat:@"尺寸: %@\n大小: %.1f MB", dimensions, sizeInMB];
    
    // 设置图片信息标签约束
    self.imageInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.imageInfoLabel.leadingAnchor constraintEqualToAnchor:self.bottomView.leadingAnchor constant:20],
        [self.imageInfoLabel.centerYAnchor constraintEqualToAnchor:self.bottomView.centerYAnchor],
        [self.imageInfoLabel.trailingAnchor constraintEqualToAnchor:self.bottomView.centerXAnchor constant:-10]
    ]];
    
    // 关闭按钮
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.dismissButton setTitle:@"关闭" forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissButton.backgroundColor = [UIColor systemBlueColor];
    self.dismissButton.layer.cornerRadius = 20;
    [self.dismissButton addTarget:self action:@selector(dismissButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.dismissButton];
    
    // 设置关闭按钮约束
    self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.dismissButton.trailingAnchor constraintEqualToAnchor:self.bottomView.trailingAnchor constant:-20],
        [self.dismissButton.centerYAnchor constraintEqualToAnchor:self.bottomView.centerYAnchor],
        [self.dismissButton.widthAnchor constraintEqualToConstant:80],
        [self.dismissButton.heightAnchor constraintEqualToConstant:40]
    ]];
}

- (void)dismissButtonTapped {
    [self animateDismissal];
}

- (void)setupGestureRecognizers {
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    // 平移手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    
    // 添加双指缩放手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGesture];
}

#pragma mark - Layout Methods

- (CGRect)calculateTargetFrame {
    // 这个方法不再需要，因为我们使用 UIPageViewController 来管理图片视图
    return self.view.bounds;
}

#pragma mark - Animation Methods

- (void)animateImagePresentation {
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.imageView.frame = self.targetFrame;
        self.view.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self updateScrollViewContentSize];
        [self updateScrollViewZoomScales];
    }];
}

- (void)animateDismissal {
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:self.completionBlock];
    }];
}

- (void)resetImageViewPosition {
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = self.targetFrame;
        self.view.backgroundColor = [UIColor blackColor];
    } completion:nil];
}

#pragma mark - Gesture Handlers

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint location = [gesture locationInView:self.imageView];
        CGFloat targetZoomScale = self.scrollView.maximumZoomScale;
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        CGFloat w = scrollViewSize.width / targetZoomScale;
        CGFloat h = scrollViewSize.height / targetZoomScale;
        CGFloat x = location.x - (w / 2.0);
        CGFloat y = location.y - (h / 2.0);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = 1.0 - fabs(translation.y) / self.view.bounds.size.height;
            scale = MAX(scale, 0.5);
            self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
            self.imageView.center = CGPointMake(self.imageView.center.x + translation.x,
                                              self.imageView.center.y + translation.y);
            [gesture setTranslation:CGPointZero inView:self.view];
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scale];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat verticalVelocity = fabs(velocity.y);
            if (verticalVelocity > 1000 || fabs(translation.y) > 100) {
                [self animateDismissal];
            } else {
                [self resetImageViewPosition];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 记录初始transform
        gesture.view.transform = self.imageView.transform;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateChanged) {
        
        // 获取手势中心点
        CGPoint center = [gesture locationInView:self.view];
        
        // 计算相对于图片中心的偏移
        CGPoint imageCenter = self.imageView.center;
        CGPoint offset = CGPointMake(center.x - imageCenter.x, center.y - imageCenter.y);
        
        // 创建变换矩阵
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        // 移动到手势中心点
        transform = CGAffineTransformTranslate(transform, offset.x, offset.y);
        
        // 应用缩放
        transform = CGAffineTransformScale(transform, gesture.scale, gesture.scale);
        
        // 移回原位置
        transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y);
        
        // 限制最小和最大缩放
        CGFloat currentScale = sqrt(pow(self.imageView.transform.a, 2) + pow(self.imageView.transform.b, 2));
        CGFloat newScale = currentScale * gesture.scale;
        
        if (newScale >= 0.5 && newScale <= 3.0) {
            self.imageView.transform = CGAffineTransformConcat(self.imageView.transform, transform);
        }
        
        // 重置scale以避免累积效应
        gesture.scale = 1.0;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // 获取当前缩放比例
        CGFloat currentScale = sqrt(pow(self.imageView.transform.a, 2) + pow(self.imageView.transform.b, 2));
        
        // 如果缩放比例小于1，动画恢复到原始大小
        if (currentScale < 1.0) {
            [UIView animateWithDuration:0.3
                                delay:0
               usingSpringWithDamping:0.8
                initialSpringVelocity:0.2
                              options:UIViewAnimationOptionCurveEaseOut
                           animations:^{
                self.imageView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

#pragma mark - ScrollView Methods

- (void)updateScrollViewContentSize {
    self.scrollView.contentSize = self.imageView.frame.size;
}

- (void)updateScrollViewZoomScales {
    CGFloat minScale = 1.0;
    CGFloat maxScale = 3.0;
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.zoomScale = minScale;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    self.imageView.frame = frameToCenter;
}

- (void)setupSingleImageView {
    // 设置单个图片视图
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
    
    // 更新底部信息
    [self updateImageInfo:self.image];
}

- (void)loadMoreImages:(BOOL)isLoadingNext {
    if (self.isLoadingMore) return;
    
    self.isLoadingMore = YES;
    
    // 显示加载指示器
    [self showLoadingIndicator];
    
    // 获取更多图片
    [[URLFetcher sharedInstance] fetchURLsWithCategory:self.category andCurrentId:self.currentPage andCompletion:^(NSArray * _Nonnull fetchedArray) {
        [self hideLoadingIndicator];
        self.isLoadingMore = NO;
        
        if (fetchedArray.count > 0) {
            self.currentPage += 1;
            
            // 提取 URL 并去重
            NSMutableArray *newUrls = [NSMutableArray array];
            NSMutableSet *existingUrls = [NSMutableSet setWithArray:self.imageUrls];
            
            for (HomeModel *model in fetchedArray) {
                if (model.url && ![existingUrls containsObject:model.url]) {
                    [newUrls addObject:model.url];
                    [existingUrls addObject:model.url];
                }
            }
            
            // 如果没有新的URL，不更新
            if (newUrls.count == 0) {
                return;
            }
            
            // 更新图片数组
            NSMutableArray *updatedUrls = [NSMutableArray arrayWithArray:self.imageUrls];
            if (isLoadingNext) {
                [updatedUrls addObjectsFromArray:newUrls];
            } else {
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newUrls.count)];
                [updatedUrls insertObjects:newUrls atIndexes:indexes];
                self.currentIndex += newUrls.count;
            }
            self.imageUrls = updatedUrls;
            
            // 更新源视图控制器
            if ([self.sourceViewController isKindOfClass:[BaseCollectionListViewController class]]) {
                BaseCollectionListViewController *collectionVC = (BaseCollectionListViewController *)self.sourceViewController;
                [collectionVC updateItems:fetchedArray];
            }
        }
    }];
}

- (void)setupLoadingIndicator {
    // 创建加载指示器容器
    UIView *loadingContainer = [[UIView alloc] init];
    loadingContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    loadingContainer.layer.cornerRadius = 10;
    [self.view addSubview:loadingContainer];
    
    // 设置约束
    loadingContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [loadingContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [loadingContainer.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [loadingContainer.widthAnchor constraintEqualToConstant:120],
        [loadingContainer.heightAnchor constraintEqualToConstant:80]
    ]];
    
    // 创建加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingContainer addSubview:self.loadingIndicator];
    
    // 设置加载指示器约束
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:loadingContainer.centerXAnchor],
        [self.loadingIndicator.topAnchor constraintEqualToAnchor:loadingContainer.topAnchor constant:15]
    ]];
    
    // 创建加载标签
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.text = @"加载中...";
    self.loadingLabel.textColor = [UIColor whiteColor];
    self.loadingLabel.font = [UIFont systemFontOfSize:14];
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    [loadingContainer addSubview:self.loadingLabel];
    
    // 设置加载标签约束
    self.loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingLabel.centerXAnchor constraintEqualToAnchor:loadingContainer.centerXAnchor],
        [self.loadingLabel.topAnchor constraintEqualToAnchor:self.loadingIndicator.bottomAnchor constant:10],
        [self.loadingLabel.leadingAnchor constraintEqualToAnchor:loadingContainer.leadingAnchor constant:10],
        [self.loadingLabel.trailingAnchor constraintEqualToAnchor:loadingContainer.trailingAnchor constant:-10]
    ]];
    
    // 初始状态隐藏
    loadingContainer.hidden = YES;
}

- (void)showLoadingIndicator {
    self.loadingIndicator.superview.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoadingIndicator {
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.superview.hidden = YES;
}

@end
