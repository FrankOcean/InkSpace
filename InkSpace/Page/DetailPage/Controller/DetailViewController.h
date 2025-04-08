//
//  DetailViewController.h
//  InkSpace
//
//  Created by puyang on 2024/9/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PhotoViewCompletionBlock)(void);


@interface DetailViewController : UIViewController

@property (nonatomic, strong) NSArray<NSString *> *imageUrls;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) id sourceViewController;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isLoadingMore;

+ (void)showImage:(UIImage *)image fromImageView:(UIImageView *)sourceImageView completion:(nullable PhotoViewCompletionBlock)completion;
+ (void)showImages:(NSArray<NSString *> *)imageUrls currentIndex:(NSInteger)index fromImageView:(UIImageView *)sourceImageView sourceViewController:(id)sourceVC completion:(nullable PhotoViewCompletionBlock)completion;
+ (void)showImages:(NSArray<NSString *> *)imageUrls currentIndex:(NSInteger)index category:(NSInteger)category currentPage:(NSInteger)currentPage fromImageView:(UIImageView *)sourceImageView sourceViewController:(id)sourceVC completion:(nullable PhotoViewCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
