//
//  StoreManager.m
//  InkSpace
//
//  Created by puyang on 2024/9/15.
//

#import "StoreManager.h"

@implementation StoreManager

+ (instancetype)sharedManager {
    static StoreManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager loadModelsFromCache];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _models = [NSMutableArray array];
    }
    return self;
}

- (void)addModel:(HomeModel *)model {
    if (!model) return;
    
    // 添加模型到列表
    if (![self.models containsObject:model]) {
        [self.models addObject:model];
    }
    
    // 缓存到本地
    [self saveModelsToCache];
}

- (NSArray<HomeModel *> *)getAllModels {
    return [self.models copy];
}

- (void)saveModelsToCache {
    NSMutableArray *modelDictionaries = [NSMutableArray array];
    for (HomeModel *model in self.models) {
        NSDictionary *dict = @{
            @"id": @(model.ID),
            @"name": model.name ?: @"",
            @"resolution": model.resolution ?: @"",
            @"category": model.category ?: @"",
            @"description": model.desc ?: @"",
            @"url": model.url ?: @"",
            @"favorite": @(model.favorite)
        };
        [modelDictionaries addObject:dict];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:modelDictionaries forKey:@"HomeModelCache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadModelsFromCache {
    NSArray *modelDictionaries = [[NSUserDefaults standardUserDefaults] objectForKey:@"HomeModelCache"];
    if (modelDictionaries) {
        for (NSDictionary *dict in modelDictionaries) {
            HomeModel *model = [[HomeModel alloc] init];
            model.ID = [dict[@"id"] unsignedIntValue];
            model.name = dict[@"name"];
            model.resolution = dict[@"resolution"];
            model.category = dict[@"category"];
            model.desc = dict[@"description"];
            model.url = dict[@"url"];
            model.favorite = [dict[@"favorite"] unsignedIntValue];
            
            [self.models addObject:model];
        }
    }
}

- (void)removeModelWithID:(unsigned int)ID {
    // 查找要删除的模型
    HomeModel *modelToRemove = nil;
    for (HomeModel *model in self.models) {
        if (model.ID == ID) {
            modelToRemove = model;
            break;
        }
    }
    
    // 如果找到了，删除模型并更新缓存
    if (modelToRemove) {
        [self.models removeObject:modelToRemove];
        [self saveModelsToCache];
    }
}

@end
