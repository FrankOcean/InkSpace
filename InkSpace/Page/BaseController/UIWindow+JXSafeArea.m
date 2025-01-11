//
//  UIWindow+JXSafeArea.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/9/29.
//  Copyright © 2018 jiaxin. All rights reserved.
//

#import "UIWindow+JXSafeArea.h"

@implementation UIWindow (JXSafeArea)

- (UIWindow *)getCurrentWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        // 从正在连接活跃的 `UIWindowScene` 中获取 `UIWindow`
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
        }
    } else {
        // 对于 iOS 13 以下，仍可以安全地使用 `keyWindow`
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

- (UIEdgeInsets)jx_layoutInsets {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = self.safeAreaInsets;
        if (safeAreaInsets.bottom > 0) {
            //参考文章：https://mp.weixin.qq.com/s/Ik2zBox3_w0jwfVuQUJAUw
            return safeAreaInsets;
        }
        return UIEdgeInsetsMake(20, 0, 0, 0);
    }
    return UIEdgeInsetsMake(20, 0, 0, 0);
}

- (CGFloat)jx_navigationHeight {
    CGFloat statusBarHeight = [self jx_layoutInsets].top;
    return statusBarHeight + 44;
}


@end
