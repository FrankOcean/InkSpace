//
//  URLFetcher.h
//  InkSpace
//
//  Created by puyang on 2024/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLFetcher : NSObject

@property (strong, nonatomic) NSMutableArray *fetchedArray;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

+ (instancetype)sharedInstance;

- (void)fetchLikeCount:(NSUInteger)count andID:(NSUInteger)idk;
- (void)fetchURLsWithCompletion:(void (^)(NSArray *fetchedArray))success;
- (void)fetchURLsWithCurrentId:(NSUInteger)currentId andCompletion:(void (^)(NSArray *fetchedArray))success;
- (void)fetchURLsWithCategory:(NSUInteger)category andCompletion:(void (^)(NSArray *fetchedArray))success;
- (void)fetchURLsWithCategory:(NSUInteger)category andCurrentId:(NSUInteger)currentId andCompletion:(void (^)(NSArray *fetchedArray))success;

- (void)fetchHotURLsWithPage:(NSUInteger)page andCompletion:(void (^)(NSArray *fetchedArray))success;

- (void)fetchNewURLsWithPage:(NSUInteger)page andCompletion:(void (^)(NSArray *fetchedArray))success;

- (void)fetchSearchURLsWithContent:(NSString*)content Page:(NSUInteger)page andCompletion:(void (^)(NSArray *fetchedArray))success;

- (void)fetchDeleteURLsWithID:(NSUInteger)idk;

@end

NS_ASSUME_NONNULL_END
