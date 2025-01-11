//
//  StoreManager.h
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import <Foundation/Foundation.h>
#import "HomeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface StoreManager : NSObject

@property (nonatomic, strong) NSMutableArray<HomeModel *> *models;

+ (instancetype)sharedManager;
- (void)addModel:(HomeModel *)model;
- (NSArray<HomeModel *> *)getAllModels;
- (void)removeModelWithID:(unsigned int)ID; // 删除

@end

NS_ASSUME_NONNULL_END
