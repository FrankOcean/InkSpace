//
//  UIWindow+JXSafeArea.h
//  InkSpace
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (JXSafeArea)

/// 获取当前活跃的主窗口
@property (class, nonatomic, readonly) UIWindow *mainWindow;

/// 安全区域边距
@property (nonatomic, readonly) UIEdgeInsets safeAreaInsets;

/// 状态栏高度
@property (nonatomic, readonly) CGFloat statusBarHeight;

/// 导航栏高度（包含状态栏）
@property (nonatomic, readonly) CGFloat navigationBarHeight;

/// 底部安全区域高度（比如iPhone X系列的底部黑条）
@property (nonatomic, readonly) CGFloat bottomSafeAreaHeight;

/// TabBar高度（包含底部安全区域）
@property (nonatomic, readonly) CGFloat tabBarHeight;

@end

NS_ASSUME_NONNULL_END
