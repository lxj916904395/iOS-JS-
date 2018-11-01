
//
//  WebViewJavascripBridgeViewController.m
//  iOS-html
//
//  Created by zhongding on 2018/10/31.
//

#import "WebViewJavascripBridgeViewController.h"
#import <WebKit/WebKit.h>
#import <WKWebViewJavascriptBridge.h>
#import <AVFoundation/AVFoundation.h>

@interface WebViewJavascripBridgeViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic) WKWebView   *webView;
@property WKWebViewJavascriptBridge *webViewBridge;

@end

@implementation WebViewJavascripBridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self.contentView addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
    
    _webViewBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_webViewBridge setWebViewDelegate:self];
    
    [self registerAction];
}

- (void)registerAction{
    // 监听JS的 scan 方法调用，返回结果
    [_webViewBridge registerHandler:@"scan" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"扫一扫");
        NSString *scanResult = @"http://www.baidu.com";
        responseCallback(scanResult);
    }];
    
        // 监听JS的 shake 方法调用，返回结果
    [_webViewBridge registerHandler:@"shake" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"摇一摇");
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        NSString *scanResult = @"点击摇一摇";
        responseCallback(scanResult);
    }];
}

- (WKWebView*)webView{
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUScript     = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
        
    
        
        config.userContentController = wkUController;
        
        _webView                    = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate         = self;
    }
    return _webView;
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
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
    

}

#pragma mark ***************** method

- (void)scan{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
    
    [self.webView evaluateJavaScript:@"scanResult('扫码结果')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}



@end
