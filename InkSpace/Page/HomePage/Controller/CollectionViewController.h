//
//  CollectionViewController.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "BaseCollectionListViewController.h"

@interface CollectionViewController : BaseCollectionListViewController

@property (nonatomic, assign) NSUInteger history_id;

- (instancetype)initWithCategory:(NSUInteger)category;

@end 