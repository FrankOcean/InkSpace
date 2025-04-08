//
//  HistoryHomeController.m
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import "HistoryHomeController.h"
#import "HistoryCollectionViewController.h"
#import "HomeModel.h"
#import "HomeViewCell.h"

@interface HistoryHomeController ()

@property (nonatomic, strong) NSArray *items;

@end

@implementation HistoryHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史记录";
    self.items = @[@"超清", @"人物", @"动漫", @"美女"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *selectedItem = self.items[indexPath.row];
    NSInteger category = 0;
    // 根据选择项执行相应操作
    if ([selectedItem isEqualToString:@"超清"]) {
        category = 2;
    } else if ([selectedItem isEqualToString:@"人物"]) {
        category = 3;
    } else if ([selectedItem isEqualToString:@"动漫"]) {
        category = 1;
    } else if ([selectedItem isEqualToString:@"美女"]) {
        category = 0;
    }
    HistoryCollectionViewController *hisVC = [[HistoryCollectionViewController alloc] init];
    hisVC.category = category;
    [self.navigationController pushViewController:hisVC animated:YES];
    
}

@end
