#import "PYCategoryView.h"

@interface PYCategoryView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *titleWidths;
@property (nonatomic, strong, readwrite) UIView *searchView;
@property (nonatomic, strong, readwrite) UIButton *searchButton;
@property (nonatomic, assign) CGFloat searchViewHeight;
@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, assign) CGFloat categoryHeight;

@end

@implementation PYCategoryView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles {
    self = [super initWithFrame:frame];
    if (self) {
        _titles = titles;
        _buttons = [NSMutableArray array];
        _titleWidths = [NSMutableArray array];
        _selectedIndex = 0;
        _searchViewHeight = 40;
        _categoryHeight = 44;
        _buttonWidth = frame.size.width / titles.count;
        [self setupSearchView];
        [self setupUI];
    }
    return self;
}

- (void)setupSearchView {
    // Setup search container view
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.searchViewHeight)];
    self.searchView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.searchView];
    
    // Setup search button
    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.searchButton.frame = CGRectMake(10, 5, self.frame.size.width - 20, 30);
    [self.searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
    self.searchButton.layer.borderWidth = 1;
    self.searchButton.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.searchButton.layer.cornerRadius = 5;
    [self.searchButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:self.searchButton];
}

- (void)setupUI {
    // Setup scrollView below search view
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.searchViewHeight, self.frame.size.width, self.categoryHeight)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scrollView];
    
    // Create buttons
    CGFloat currentX = 0;
    for (NSInteger i = 0; i < self.titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(currentX, 0, self.buttonWidth, self.categoryHeight - 2);
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [self.buttons addObject:button];
        
        // Calculate title width for indicator
        CGSize titleSize = [self.titles[i] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: button.titleLabel.font}
                                                      context:nil].size;
        [self.titleWidths addObject:@(titleSize.width)];
        
        currentX += self.buttonWidth;
    }
    
    // Setup indicator with initial width
    CGFloat initialWidth = [self.titleWidths[0] floatValue];
    UIButton *firstButton = self.buttons[0];
    CGFloat indicatorX = firstButton.frame.origin.x + (self.buttonWidth - initialWidth) / 2;
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(indicatorX, self.categoryHeight - 2, initialWidth, 2)];
    self.indicatorView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:self.indicatorView];
    
    // Select first button by default
    [self selectButtonAtIndex:0 animated:NO];
}

- (void)updateSearchViewWithOffset:(CGFloat)offset {
    // Only update the category view position, keep search view fixed
    CGFloat maxOffset = self.searchViewHeight;
    CGFloat yOffset = -MIN(offset, maxOffset);
    
    // Update scrollView position
    CGFloat scrollViewY = MAX(0, self.searchViewHeight + yOffset);
    self.scrollView.frame = CGRectMake(0, scrollViewY, self.frame.size.width, self.categoryHeight);
}

- (void)searchButtonClicked {
    if ([self.delegate respondsToSelector:@selector(categoryView:didClickSearchButton:)]) {
        [self.delegate categoryView:self didClickSearchButton:@""];
    }
}

- (void)buttonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    [self selectButtonAtIndex:index animated:YES];
    if ([self.delegate respondsToSelector:@selector(categoryView:didSelectItemAtIndex:)]) {
        [self.delegate categoryView:self didSelectItemAtIndex:index];
    }
}

- (void)selectButtonAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= self.buttons.count) return;
    
    _selectedIndex = index;
    
    for (UIButton *button in self.buttons) {
        BOOL isSelected = (button.tag == index);
        button.selected = isSelected;
        button.titleLabel.font = isSelected ? [UIFont boldSystemFontOfSize:15] : [UIFont systemFontOfSize:15];
        [button setTitleColor:isSelected ? [UIColor blackColor] : [UIColor grayColor] forState:UIControlStateNormal];
    }
    
    // 直接更新下划线位置，不使用动画
    UIButton *selectedButton = self.buttons[index];
    CGFloat titleWidth = [self.titleWidths[index] floatValue];
    CGFloat indicatorX = selectedButton.frame.origin.x + (self.buttonWidth - titleWidth) / 2;
    self.indicatorView.frame = CGRectMake(indicatorX, self.categoryHeight - 2, titleWidth, 2);
    
    // Center the selected button
    CGFloat offsetX = selectedButton.center.x - (self.frame.size.width / 2);
    offsetX = MAX(0, MIN(offsetX, self.scrollView.contentSize.width - self.scrollView.frame.size.width));
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)updateIndicatorWithScrollView:(UIScrollView *)scrollView {
    CGFloat progress = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger leftIndex = floor(progress);
    NSInteger rightIndex = ceil(progress);
    CGFloat percent = progress - leftIndex;
    
    if (leftIndex < 0 || rightIndex >= self.buttons.count) return;
    
    // Update button states
    for (UIButton *button in self.buttons) {
        NSInteger index = button.tag;
        if (index == leftIndex || index == rightIndex) {
            CGFloat alpha = (index == leftIndex) ? (1 - percent) : percent;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [button setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:MAX(alpha, 0.5)] forState:UIControlStateNormal];
        } else {
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    
    [self updateIndicatorFrameWithIndex:leftIndex percent:percent toIndex:rightIndex];
}

- (void)updateIndicatorFrameWithIndex:(NSInteger)index percent:(CGFloat)percent toIndex:(NSInteger)toIndex {
    if (index < 0 || toIndex >= self.buttons.count) return;
    
    CGFloat leftTitleWidth = [self.titleWidths[index] floatValue];
    CGFloat rightTitleWidth = [self.titleWidths[toIndex] floatValue];
    
    UIButton *leftButton = self.buttons[index];
    UIButton *rightButton = self.buttons[toIndex];
    
    CGFloat leftX = leftButton.frame.origin.x + (self.buttonWidth - leftTitleWidth) / 2;
    CGFloat rightX = rightButton.frame.origin.x + (self.buttonWidth - rightTitleWidth) / 2;
    
    CGFloat indicatorWidth = leftTitleWidth + (rightTitleWidth - leftTitleWidth) * percent;
    CGFloat indicatorX = leftX + (rightX - leftX) * percent;
    
    self.indicatorView.frame = CGRectMake(indicatorX, self.categoryHeight - 2, indicatorWidth, 2);
}

- (UIColor *)colorWithGrayAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
}

@end
