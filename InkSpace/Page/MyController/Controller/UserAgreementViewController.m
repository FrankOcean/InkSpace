#import "UserAgreementViewController.h"

@interface UserAgreementViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation UserAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = self.agreementTitle ?: @"用户服务协议";
    
    // 配置 WKWebView
    [self setupWebView];
    
    // 配置加载指示器
    [self setupActivityIndicator];
    
    // 加载本地 HTML 文件
    [self loadLocalHTML];
}

- (void)setupWebView {
    // 创建 WKWebView 配置
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    
    // 创建 WKWebView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.backgroundColor = [UIColor systemBackgroundColor];
    
    // 添加到视图层级
    [self.view addSubview:self.webView];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
}

- (void)loadLocalHTML {
    // 获取本地 HTML 文件路径
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"user_agreement" ofType:@"html"];
    if (htmlPath) {
        NSURL *fileURL = [NSURL fileURLWithPath:htmlPath];
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];
    } else {
        // 处理文件未找到的情况
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                     message:@"无法加载用户协议"
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.activityIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    
    // 处理加载失败的情况
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败"
                                                                 message:error.localizedDescription
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
