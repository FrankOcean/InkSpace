//
//  BaseCollectionViewController.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//  viewcontroller和hotviewcontroller的基控制器（CollectionView版本）

/*
 BaseCollectionViewController (基础CollectionView功能)
 └── BaseCollectionListViewController (通用列表功能)
     ├── CollectionViewController (分类浏览)
     └── HotCollectionViewController (最新/最热/搜索)
 */

#import <UIKit/UIKit.h>
#import "JXCategoryListContainerView.h"

@interface BaseCollectionViewController : UIViewController <JXCategoryListContentViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat topOffset;

- (void)setupCollectionView;
- (void)standardHeader;
- (void)loadData;
- (void)hideLoading;

@end 