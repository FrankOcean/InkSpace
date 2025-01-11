//
//  FootballViewController.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/10.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "FootViewController.h"
#import "UIWindow+JXSafeArea.h"

@interface FootViewController ()
@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;
@property (nonatomic, assign) CGFloat topSafeArea;

@end

@implementation FootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"最新", @"最热", @"超清", @"人物", @"动漫", @"美女"];
    
    self.isNeedIndicatorPositionChangeItem = YES;

    // 初始化分页菜单视图
    self.myCategoryView.titles = self.titles;
    self.myCategoryView.titleColorGradientEnabled = YES;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.topSafeArea = 0;
    
    if ([self hasDynamicIsland]) {
        self.topSafeArea = self.view.safeAreaInsets.top;
    }
    
    // 设置categoryView的frame，考虑安全区域和灵动岛
    self.categoryView.frame = CGRectMake(50, self.topSafeArea, self.view.bounds.size.width - 50 - 15, [self preferredCategoryViewHeight]);
    self.listContainerView.frame = CGRectMake(0, [self preferredCategoryViewHeight], self.view.bounds.size.width, self.view.bounds.size.height);
    
}

- (JXCategoryTitleView *)myCategoryView {
    return (JXCategoryTitleView *)self.categoryView;
}

- (JXCategoryBaseView *)preferredCategoryView {
    return [[JXCategoryTitleView alloc] init];
}

- (CGFloat)preferredCategoryViewHeight {
    return 40;
}

@end
