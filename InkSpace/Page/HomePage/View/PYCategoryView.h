#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PYCategoryViewDelegate <NSObject>

- (void)categoryView:(UIView *)categoryView didSelectItemAtIndex:(NSInteger)index;
- (void)categoryView:(UIView *)categoryView didClickSearchButton:(NSString *)searchText;
- (void)categoryView:(UIView *)categoryView didClickProfileButton:(NSString *)text;
@end

@interface PYCategoryView : UIView

@property (nonatomic, weak) id<PYCategoryViewDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong, readonly) UIView *searchView;
@property (nonatomic, strong, readonly) UITextField *searchTextField;
@property (nonatomic, strong, readonly) UIButton *searchButton;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles;
- (void)updateIndicatorWithScrollView:(UIScrollView *)scrollView;
- (void)updateSearchViewWithOffset:(CGFloat)offset;

@end

NS_ASSUME_NONNULL_END
