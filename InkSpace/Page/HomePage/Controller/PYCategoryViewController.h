#import <UIKit/UIKit.h>

/*
 viewcontroller和hotviewcontroller,以及searchviewcontroller的承载控制器
 */

NS_ASSUME_NONNULL_BEGIN

@interface PYCategoryViewController : UIViewController

@property (nonatomic, strong, readonly) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong, readonly) NSArray<NSString *> *titles;

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
                               titles:(NSArray<NSString *> *)titles;

@end

NS_ASSUME_NONNULL_END
