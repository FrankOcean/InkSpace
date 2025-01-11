//
//  ViewController.h
//  InkSpace
//
//  Created by puyang on 2024/6/14.
//

#import "BaseListViewController.h"

@interface ViewController : BaseListViewController

@property (assign, nonatomic) NSUInteger category;
@property (nonatomic, assign) NSUInteger history_id;

- (instancetype)initWithCategory:(NSUInteger)category;

@end
