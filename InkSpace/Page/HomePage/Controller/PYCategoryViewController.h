#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PYCategoryViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong, readonly) NSArray<NSString *> *titles;

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                               titles:(NSArray<NSString *> *)titles;

@end

NS_ASSUME_NONNULL_END
