//
//  HotViewController.m
//  InkSpace
//
//  Created by puyang on 2024/9/12.
//

#import "HotViewController.h"
#import "URLFetcher.h"

@implementation HotViewController

- (instancetype)initWithCategory:(ContentType)category {
    self = [super init];
    if (self) {
        _contentType = category;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - BaseListViewController

- (void)fetchInitialData:(void(^)(NSArray *fetchedArray))completion {
    self.currentPage = 0;
    if (self.contentType == ContentTypeNewest) {
        [[URLFetcher sharedInstance] fetchNewURLsWithPage:self.currentPage andCompletion:completion];
    } else if (self.contentType == ContentTypeHottest) {
        [[URLFetcher sharedInstance] fetchHotURLsWithPage:self.currentPage andCompletion:completion];
    } else {
        if (self.content.length == 0) { self.content = @""; }
        [[URLFetcher sharedInstance] fetchSearchURLsWithContent:self.content Page:self.currentPage andCompletion:completion];
    }
}

- (void)fetchMoreData:(void(^)(NSArray *fetchedArray))completion {
    self.currentPage += 1;
    if (self.contentType == ContentTypeNewest) {
        [[URLFetcher sharedInstance] fetchNewURLsWithPage:self.currentPage andCompletion:completion];
    } else if (self.contentType == ContentTypeHottest) {
        [[URLFetcher sharedInstance] fetchHotURLsWithPage:self.currentPage andCompletion:completion];
    } else {
        if (self.content.length == 0) { self.content = @""; }
        [[URLFetcher sharedInstance] fetchSearchURLsWithContent:self.content Page:self.currentPage andCompletion:completion];
    }
}

@end
