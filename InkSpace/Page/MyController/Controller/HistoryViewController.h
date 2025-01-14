//
//  HistoryViewController.h
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import <UIKit/UIKit.h>
#import "BaseListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HistoryViewController : BaseListViewController

@property (nonatomic, assign) NSUInteger category;
@property (nonatomic, assign) NSUInteger history_id;

@end

NS_ASSUME_NONNULL_END
