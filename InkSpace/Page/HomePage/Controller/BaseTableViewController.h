//
//  BaseTableViewController.h
//  InkSpace
//
//  Created by puyang on 2025/1/10.
//  viewcontroller和hotviewcontroller的基控制器

/*
 BaseTableViewController (基础TableView功能)
 └── BaseListViewController (通用列表功能)
     ├── ViewController (分类浏览)
     └── HotViewController (最新/最热/搜索)
 */

#import <UIKit/UIKit.h>
#import "JXCategoryListContainerView.h"

@interface BaseTableViewController : UIViewController <JXCategoryListContentViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, assign) CGFloat topOffset;

- (void)setupTableView;
- (void)standardHeader;
- (void)loadData;

@end
