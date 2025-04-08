//
//  BaseCollectionViewController.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "BaseCollectionViewController.h"
#import "HomeCollectionViewCell.h"
#import "WaterfallFlowLayout.h"

@interface BaseCollectionViewController () <WaterfallFlowLayoutDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) WaterfallFlowLayout *flowLayout;

@end

@implementation BaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self standardHeader];
    [self loadData];
}

- (void)setupCollectionView {
    self.flowLayout = [[WaterfallFlowLayout alloc] init];
    self.flowLayout.delegate = self;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // 注册cell
    [self.collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    
    [self.view addSubview:self.collectionView];
    
    // 设置加载指示器
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _loadingIndicator.center = self.view.center;
    [self.view addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
}

- (WaterfallFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[WaterfallFlowLayout alloc] init];
        _flowLayout.delegate = self;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView.scrollIndicatorInsets = _collectionView.contentInset;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    }
    return _collectionView;
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

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0; // 子类实现
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil; // 子类实现
}

#pragma mark - WaterfallFlowLayoutDelegate

// 必须实现的方法 - 返回item高度
- (CGFloat)waterfallLayout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    // 子类实现
    return itemWidth * 1.5;
}

// 返回列数
- (NSInteger)columnCountInWaterfallLayout:(UICollectionViewLayout *)layout {
    return 2; // 默认2列
}

// 返回列间距
- (CGFloat)columnMarginInWaterfallLayout:(UICollectionViewLayout *)layout {
    return 0.0;
}

// 返回行间距
- (CGFloat)rowMarginInWaterfallLayout:(UICollectionViewLayout *)layout {
    return 0.0;
}

// 返回内边距
- (UIEdgeInsets)edgeInsetsInWaterfallLayout:(UICollectionViewLayout *)layout {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

// 添加显示和隐藏 loading 的方法
- (void)showLoading {
    [self.loadingIndicator startAnimating];
}

- (void)hideLoading {
    [self.loadingIndicator stopAnimating];
}

@end 
