#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailImageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

- (void)setupWithImage:(UIImage *)image;
- (void)loadImageWithURL:(NSString *)url completion:(void(^)(UIImage * _Nullable image))completion;

@end

NS_ASSUME_NONNULL_END 