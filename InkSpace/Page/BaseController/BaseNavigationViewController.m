//
//  BaseNavigationViewController.m
//  JXCategoryView
//
//  Created by jiaxin on 2019/3/4.
//  Copyright © 2019 jiaxin. All rights reserved.
//

#import "BaseNavigationViewController.h"

@interface BaseNavigationViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation BaseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count == 1) {
        return NO;
    }
    return YES;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    // If the view controller to be shown is the root view controller
    BOOL isRootViewController = (viewController == [navigationController.viewControllers firstObject]);
    NSLog(@"%@", viewController);
    NSLog(@"%@", [navigationController.viewControllers firstObject]);
    NSLog(@"%d", isRootViewController);

    
    // 控制 tabBar 的显示和隐藏
    viewController.hidesBottomBarWhenPushed = !isRootViewController;
}

@end
