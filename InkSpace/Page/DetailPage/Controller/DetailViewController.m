//
//  DetailViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/3.
//

#import "DetailViewController.h"

@interface DetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) UIImageView *sourceImageView;
@property (nonatomic, copy) PhotoViewCompletionBlock completionBlock;
@property (nonatomic, assign) CGRect sourceFrame;
@property (nonatomic, assign) CGRect targetFrame;
@property (nonatomic, assign) CGSize sourceImageSize;

// 新增的UI元素
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *imageInfoLabel;
@property (nonatomic, strong) UIButton *dismissButton;

@end

@implementation DetailViewController


+ (void)showImage:(UIImage *)image fromImageView:(UIImageView *)sourceImageView completion:(PhotoViewCompletionBlock)completion {
    if (!image) return;
    
    DetailViewController *photoVC = [[DetailViewController alloc] init];
    photoVC.image = image;
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
        // 降级方案，用于不支持多场景的旧版本
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
    [self setupScrollView];
    [self setupImageView];
    [self setupBottomView];
    [self setupGestureRecognizers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 确保源 ImageView 已经完成布局
    [self.sourceImageView.superview layoutIfNeeded];
    
    // 获取源图片在其容器中的实际显示尺寸
    CGSize imageSize = self.image.size;
    CGSize containerSize = self.sourceImageView.bounds.size;
    CGFloat scale = MIN(containerSize.width / imageSize.width, containerSize.height / imageSize.height);
    self.sourceImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    
    // 计算源frame和目标frame
    CGRect actualFrame = [self.sourceImageView.superview convertRect:self.sourceImageView.frame toView:nil];
    
    // 计算居中的sourceFrame
    CGFloat x = actualFrame.origin.x + (actualFrame.size.width - self.sourceImageSize.width) / 2;
    CGFloat y = actualFrame.origin.y + (actualFrame.size.height - self.sourceImageSize.height) / 2;
    self.sourceFrame = CGRectMake(x, y, self.sourceImageSize.width, self.sourceImageSize.height);
    
    self.targetFrame = [self calculateTargetFrame];
    
    // 设置初始位置
    self.imageView.frame = self.sourceFrame;
    
    // 执行展示动画
    [self animateImagePresentation];
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
    NSString *dimensions = [NSString stringWithFormat:@"%dx%d", (int)self.image.size.width, (int)self.image.size.height];
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
    CGSize imageSize = self.image.size;
    CGSize boundsSize = self.view.bounds.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    CGSize scaledSize = CGSizeMake(imageSize.width * minScale, imageSize.height * minScale);
    CGFloat x = (boundsSize.width - scaledSize.width) / 2.0;
    CGFloat y = (boundsSize.height - scaledSize.height) / 2.0;
    
    return CGRectMake(x, y, scaledSize.width, scaledSize.height);
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

@end
