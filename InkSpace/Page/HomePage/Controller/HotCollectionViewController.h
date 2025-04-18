//
//  HotCollectionViewController.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "BaseCollectionListViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ContentType) {
    ContentTypeNewest,  // 最新
    ContentTypeHottest, // 最热
    ContentTypeSearch   // 搜索
};

@interface HotCollectionViewController : BaseCollectionListViewController

@property (nonatomic, assign) ContentType contentType;
@property (nonatomic, copy) NSString *content;

- (instancetype)initWithCategory:(ContentType)category;

@end

NS_ASSUME_NONNULL_END 