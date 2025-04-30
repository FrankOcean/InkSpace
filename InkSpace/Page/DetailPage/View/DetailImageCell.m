#import "DetailImageCell.h"
#import <SDWebImage/SDWebImageDownloader.h>

@implementation DetailImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 设置 imageView
    self.customImageView = [[UIImageView alloc] init];
    self.customImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.customImageView.tag = 100;
    [self.contentView addSubview:self.customImageView];
    
    // 设置约束
    self.customImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.customImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.customImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.customImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.customImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
    ]];
    
    // 设置加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.contentView addSubview:self.loadingIndicator];
    
    // 设置加载指示器约束
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
    ]];
}

- (void)setupWithImage:(UIImage *)image {
    self.customImageView.image = image;
}

- (void)loadImageWithURL:(NSString *)url completion:(void(^)(UIImage * _Nullable image))completion {
    [self.loadingIndicator startAnimating];
    
    // 使用 thumbnail640URL 处理 URL
    NSString *processedUrl = thumbnail640URL(url);
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:processedUrl] 
                                                         options:SDWebImageDownloaderHighPriority 
                                                        progress:nil 
                                                       completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        [self.loadingIndicator stopAnimating];
        
        if (image && finished) {
            self.customImageView.image = image;
            if (completion) {
                completion(image);
            }
        } else {
            self.customImageView.image = [UIImage imageNamed:@"Default.png"];
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.customImageView.image = nil;
    [self.loadingIndicator stopAnimating];
}

@end 
