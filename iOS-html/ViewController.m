

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>

static NSString * const scan = @"scan";
static NSString *const shake = @"shake";

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UIImagePickerControllerDelegate>
@property (strong, nonatomic) WKWebView   *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentView addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.html" withExtension:nil];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
 
}

- (WKWebView*)webView{
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUScript     = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
     
        
        //注册方法，js需要调用的原生方法
        [wkUController addScriptMessageHandler:self name:@"scan"];
        [wkUController addScriptMessageHandler:self name:@"add"];
        [wkUController addScriptMessageHandler:self name:@"shake"];

        config.userContentController = wkUController;
        
        _webView                    = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate         = self;
    }
    return _webView;
}

#pragma mark ***************** 原生调用JS
- (IBAction)toJS:(id)sender {
    NSString *alert = @"showAlert('原生调用js弹窗')";
    [self.webView evaluateJavaScript:alert completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            
        }
    }];
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.title = webView.title;
}


#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{

    if ([message.name isEqualToString:@"scan"]) {
        //调用原生扫码
        [self scan];
        
    }else if ([message.name isEqualToString:@"addImage"]) {
        //调用原生扫码

    }else if ([message.name isEqualToString:@"shake"]) {
        //摇一摇
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
}

#pragma mark ***************** method

- (void)scan{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
    
    [self.webView evaluateJavaScript:@"scanResult('扫码结果')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}



#pragma mark - 解析URL地址
- (NSMutableDictionary *)decoderUrl:(NSURL *)URL{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByRemovingPercentEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    return tempDic;
}


#pragma mark - 大小适应
- (WKUserContentController *)wkwebViewScalPreferences{
    
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    return wkUController;
}

//#pragma mark - WKNavigationDelegate
////请求之前，决定是否要跳转:用户点击网页上的链接，需要打开新页面时，将先调用这个方法。
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
////接收到相应数据后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
////页面开始加载时调用
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
//// 主机地址被重定向时调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
//// 页面加载失败时调用
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
//// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;
//// 页面加载完毕时调用
//- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation;
////跳转失败时调用
//- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
//// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler;
////9.0才能使用，web内容处理中断时会触发
//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0);


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
