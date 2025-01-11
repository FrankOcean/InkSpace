//
//  URLFetcher.m
//  InkSpace
//
//  Created by puyang on 2024/6/17.
//

#import "URLFetcher.h"
#import "HomeModel.h"

@implementation URLFetcher

+ (instancetype)sharedInstance {
    static URLFetcher *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.fetchedArray = [[NSMutableArray alloc] init];
        // 实例化啊
        sharedInstance.sessionManager = [AFHTTPSessionManager manager];
        // 设置请求和响应的序列化方式
        sharedInstance.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        sharedInstance.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];

    });
    return sharedInstance;
}

- (void)fetchLikeCount:(NSUInteger)count andID:(NSUInteger)idk{
    NSString *urlString = base_like_wallpaperURL((unsigned int)idk);
    [self.sessionManager POST:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response: %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Response: %@", error.description);
    }];
}

- (void)fetchURLsWithCompletion:(void (^)(NSArray *fetchedArray))success {
    
    NSString *urlString = base_wallpaper_cursor(0, 0);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"Response: %@", responseObject);
        NSArray *dataArr = responseObject[@"data"];
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:dataArr];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchURLsWithCurrentId:(NSUInteger)currentId andCompletion:(nonnull void (^)(NSArray * _Nonnull))success {
    
    NSString *urlString = base_wallpaper_cursor(0, (unsigned int)currentId);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
//        NSLog(@"Response: %@", responseObject);
        NSArray *dataArr = responseObject[@"data"];
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:dataArr];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
       
}

- (void)fetchURLsWithCategory:(NSUInteger)category andCompletion:(void (^)(NSArray *fetchedArray))success {
    NSString *urlString = base_wallpaper_cursor((unsigned int)category, 0);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *dataArr = responseObject[@"data"];
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:dataArr];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchURLsWithCategory:(NSUInteger)category andCurrentId:(NSUInteger)currentId andCompletion:(void (^)(NSArray * _Nonnull))success {
    NSString *urlString = base_wallpaper_cursor((unsigned int)(category), (unsigned int)currentId);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *dataArr = responseObject[@"data"];
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:dataArr];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchHotURLsWithPage:(NSUInteger)page andCompletion:(void (^)(NSArray *fetchedArray))success {
    NSString *urlString = base_hot_wallpaperURL((unsigned int)page);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:responseObject];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchNewURLsWithPage:(NSUInteger)page andCompletion:(void (^)(NSArray * _Nonnull))success {
    NSString *urlString = base_new_wallpaperURL((unsigned int)page);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:responseObject];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchSearchURLsWithContent:(NSString*)content Page:(NSUInteger)page andCompletion:(void (^)(NSArray *fetchedArray))success {
    NSString *urlString = base_search_wallpaperURL(content, (unsigned int)page);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        NSArray *arr = [HomeModel mj_objectArrayWithKeyValuesArray:responseObject];
        self.fetchedArray = [NSMutableArray arrayWithArray:arr];
        // 调用成功闭包
        if (success) {
            success(self.fetchedArray);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchDeleteURLsWithID:(NSUInteger)idk {
    NSString *urlString = base_del_wallpaperURL((unsigned int)idk);
    self.fetchedArray = [NSMutableArray array];
    [self.sessionManager DELETE:urlString parameters:nil headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success: %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error.description);
    }];
}

@end
