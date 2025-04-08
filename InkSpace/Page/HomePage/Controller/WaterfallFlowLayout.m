//
//  WaterfallFlowLayout.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "WaterfallFlowLayout.h"

// 默认列数
static const NSInteger kDefaultColumnCount = 2;
// 默认列间距
static const CGFloat kDefaultColumnMargin = 1;
// 默认行间距
static const CGFloat kDefaultRowMargin = 1;
// 默认内边距
static const UIEdgeInsets kDefaultInsets = {1, 1, 1, 1};

@interface WaterfallFlowLayout()

// 所有item的布局属性
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesArray;
// 存放所有列的当前高度
@property (nonatomic, strong) NSMutableArray<NSNumber *> *columnHeights;
// 内容的高度
@property (nonatomic, assign) CGFloat contentHeight;
// 列数
@property (nonatomic, assign) NSInteger columnCount;
// 列间距
@property (nonatomic, assign) CGFloat columnMargin;
// 行间距
@property (nonatomic, assign) CGFloat rowMargin;
// 内边距
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation WaterfallFlowLayout

#pragma mark - 懒加载
- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attributesArray {
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

- (NSMutableArray<NSNumber *> *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

#pragma mark - 初始化

- (instancetype)init {
    if (self = [super init]) {
        self.columnCount = kDefaultColumnCount;
        self.columnMargin = kDefaultColumnMargin;
        self.rowMargin = kDefaultRowMargin;
        self.edgeInsets = kDefaultInsets;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
    }
    return self;
}

#pragma mark - 重写父类方法

/**
 * 初始化
 */
- (void)prepareLayout {
    [super prepareLayout];
    
    // 清除以前计算的所有布局属性
    [self.attributesArray removeAllObjects];
    
    // 初始列高度为边距
    [self.columnHeights removeAllObjects];
    for (NSInteger i = 0; i < self.columnCount; i++) {
        [self.columnHeights addObject:@(self.edgeInsets.top)];
    }
    
    // 获取每个item的布局属性
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attributesArray addObject:attributes];
    }
}

/**
 * 决定一段区域内布局属性
 */
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributesArray;
}

/**
 * 返回indexPath位置cell的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 创建布局属性
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 获取代理数据
    [self setupDelegateData];
    
    // 计算item的宽度
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    CGFloat itemWidth = (collectionViewWidth - self.edgeInsets.left - self.edgeInsets.right - (self.columnCount - 1) * self.columnMargin) / self.columnCount;
    
    // 通过代理获取item的高度
    CGFloat itemHeight = [self.delegate waterfallLayout:self heightForItemAtIndexPath:indexPath itemWidth:itemWidth];
    
    // 找出高度最小的那一列
    NSInteger minHeightColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minHeightColumn = i;
            minColumnHeight = columnHeight;
        }
    }
    
    // 计算item的x值
    CGFloat x = self.edgeInsets.left + minHeightColumn * (itemWidth + self.columnMargin);
    // 计算item的y值
    CGFloat y = minColumnHeight;
    if (y != self.edgeInsets.top) {
        y += self.rowMargin;
    }
    
    // 设置布局属性的frame
    attributes.frame = CGRectMake(x, y, itemWidth, itemHeight);
    
    // 更新最短那列的高度
    self.columnHeights[minHeightColumn] = @(CGRectGetMaxY(attributes.frame));
    
    // 记录内容的高度
    CGFloat columnHeight = [self.columnHeights[minHeightColumn] doubleValue];
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }

    return attributes;
}

/**
 * 返回内容大小
 */
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight + self.edgeInsets.bottom);
}

#pragma mark - 私有方法

/**
 * 设置代理数据
 */
- (void)setupDelegateData {
    if ([self.delegate respondsToSelector:@selector(columnCountInWaterfallLayout:)]) {
        self.columnCount = [self.delegate columnCountInWaterfallLayout:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(columnMarginInWaterfallLayout:)]) {
        self.columnMargin = [self.delegate columnMarginInWaterfallLayout:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(rowMarginInWaterfallLayout:)]) {
        self.rowMargin = [self.delegate rowMarginInWaterfallLayout:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInWaterfallLayout:)]) {
        self.edgeInsets = [self.delegate edgeInsetsInWaterfallLayout:self];
    }
}

@end 
