//
//  UIWindow+JXSafeArea.m
//  InkSpace
//
//  Created by jiaxin on 2018/9/29.
//  Copyright 2018 jiaxin. All rights reserved.
//

#import "UIWindow+JXSafeArea.h"

@implementation UIWindow (JXSafeArea)

+ (UIWindow *)mainWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
        }
    }
    
    if (!window) {
        window = UIApplication.sharedApplication.delegate.window;
    }
    
    if (!window) {
        window = UIApplication.sharedApplication.windows.firstObject;
    }
    
    return window;
}

- (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return [super safeAreaInsets];
    }
    return UIEdgeInsetsMake(20, 0, 0, 0);
}

- (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        return self.windowScene.statusBarManager.statusBarFrame.size.height;
    }
    return UIApplication.sharedApplication.statusBarFrame.size.height;
}

- (CGFloat)navigationBarHeight {
    return self.statusBarHeight + 44.0;
}

- (CGFloat)bottomSafeAreaHeight {
    return self.safeAreaInsets.bottom;
}

- (CGFloat)tabBarHeight {
    return 49.0 + self.bottomSafeAreaHeight;
}

@end

/* usage:

// 获取主窗口
UIWindow *mainWindow = UIWindow.mainWindow;

// 获取安全区域
UIEdgeInsets safeArea = mainWindow.safeAreaInsets;

// 获取导航栏高度
CGFloat navHeight = mainWindow.navigationBarHeight;

// 获取底部安全区域高度（刘海屏底部）
CGFloat bottomSafe = mainWindow.bottomSafeAreaHeight;

*/
