//
//  HistoryCollectionViewController.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import <UIKit/UIKit.h>
#import "BaseCollectionListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HistoryCollectionViewController : BaseCollectionListViewController

@property (nonatomic, assign) NSUInteger category;
@property (nonatomic, assign) NSUInteger history_id;

@end

NS_ASSUME_NONNULL_END 