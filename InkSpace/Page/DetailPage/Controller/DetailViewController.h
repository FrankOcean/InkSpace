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

+ (void)showImage:(UIImage *)image fromImageView:(UIImageView *)sourceImageView completion:(nullable PhotoViewCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
